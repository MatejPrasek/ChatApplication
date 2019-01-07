using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;


namespace SignalRChat
{
    public class ChatHub :Hub
    {
        static List<Users> ConnectedUsers = new List<Users>();
        static List<Messages> CurrentMessage = new List<Messages>();
        ConnClass ConnC = new ConnClass();

        public void Connect(string userName)
        {
            var id = Context.ConnectionId;
            if (ConnectedUsers.Count(x => x.ConnectionId == id) == 0)
            {
                string UserImg = GetUserImage(userName);
                string logintime = DateTime.Now.ToString();
                ConnectedUsers.Add(new Users { ConnectionId = id, UserName = userName, UserImage = UserImg, LoginTime = logintime });
                // send to caller
                Clients.Caller.onConnected(id, userName, ConnectedUsers, CurrentMessage);

                // send to all except caller client
                Clients.AllExcept(id).onNewUserConnected(id, userName, UserImg, logintime);

                var groups = GetUsersGroups(userName);
                foreach(string group in groups)
                {
                    Groups.Add(Context.ConnectionId, group);
                }
            }
        }

        private List<string> GetUsersGroups(string username)
        {
            return ConnC.ExecuteQuery("SELECT GroupID FROM UsersInGroups WHERE Username = '" + username + "'", 1);
        }

        public void SendMessage(string userName, string message, string time, string groupId)
        {
           string UserImg = GetUserImage(userName);

            // save message to database
            string query = "INSERT INTO Messages(Username,GroupID,Text,Time) VALUES('" + userName + "','" + groupId + "','" + message + "','" + time + "')";
            if (ConnC.ExecuteNonQuery(query) == 0)
            {
                return;
            }

            // store last 100 messages in cache
            AddMessageinCache(userName, message, time, UserImg);

            // Broad cast message
            Clients.Group(groupId).messageReceived(userName, message, time, UserImg, groupId);
        }

        // Load older messages from database 
        public void GetMessagesFromDb(string groupID, int alreadyLoaded)
        {
            int toLoad = 8;
            var data = ConnC.ExecuteQuery("SELECT* FROM(SELECT Username,Text,Time FROM Messages WHERE GroupID = '" + groupID + "' ORDER BY Time DESC OFFSET " + alreadyLoaded + " ROWS FETCH NEXT " + toLoad + " ROWS ONLY) SQ", 3);

            int count = data.Count;

            string[] username = new string[count/3];
            string[] text = new string[count/3];
            string[] time = new string[count / 3];
            string[] photo = new string[count / 3];
            for (int i = 0; i < count/3; i++)
            {
                username[i] = data[i * 3];
                text[i] = data[i * 3 + 1];
                time[i] = data[i * 3 + 2];
                photo[i] = GetUserImage(username[i]);
            }

            Clients.Caller.loadMessages(username, text, time, photo);
        }

        private void AddMessageinCache(string userName, string message, string time, string UserImg)
        {
            CurrentMessage.Add(new Messages { UserName = userName, Message = message, Time = time, UserImage = UserImg });

            if (CurrentMessage.Count > 100)
                CurrentMessage.RemoveAt(0);

        }

        // Clear Chat History
        public void clearTimeout()
        {
            CurrentMessage.Clear();
        }

        public string GetUserImage(string username)
        {
            string RetimgName = "images/dummy.png";
            try
            {
                string query = "select Photo from Users where Username='" + username + "'";
                string ImageName = ConnC.GetColumnVal(query, "Photo");

                if (ImageName != "")
                    RetimgName = "images/DP/" + ImageName;
            }
            catch (Exception ex)
            {
                throw (ex);
            }
            return RetimgName;
        }

        public override System.Threading.Tasks.Task OnDisconnected(bool stopCalled)
        {
            var item = ConnectedUsers.FirstOrDefault(x => x.ConnectionId == Context.ConnectionId);
            if (item != null)
            {
                ConnectedUsers.Remove(item);

                var id = Context.ConnectionId;
                Clients.All.onUserDisconnected(id, item.UserName);

                var groups = GetUsersGroups(item.UserName);
                foreach (string group in groups)
                {
                    Groups.Remove(item.ConnectionId, group);
                }
            }

            return base.OnDisconnected(stopCalled);
        }

        public void createGroup(string groupName, string username)
        {
            var groupId = ConnC.ExecuteQuery("INSERT INTO Groups(Name,Admin,IsPrivateChat) OUTPUT Inserted.ID VALUES('" + groupName + "','" + username + "','False')",1).FirstOrDefault();
            InsertIntoGroup(groupId, username, Context.ConnectionId);
            LoadAllGroups(username);
            Clients.Caller.selectNewChat(groupId, groupName);
        }

        public void InsertIntoGroup(string groupId, string username, string connectionId)
        {
            ConnC.ExecuteNonQuery("INSERT INTO UsersInGroups(Username,GroupID) VALUES ('" + username + "','" + groupId + "')");
            if (connectionId.Equals(string.Empty))
                return;
            Groups.Add(connectionId, groupId);
        }

        public void LoadOnlineUsers(string username)
        {
            string[] users = new string[ConnectedUsers.Count-1];
            string[] photos = new string[ConnectedUsers.Count-1];
            int j = 0;
            foreach (Users user in ConnectedUsers)
            {
                if (username == user.UserName)
                    continue;
                users[j] = user.UserName;
                photos[j] = user.UserImage;
                j++;
            }
            Clients.Caller.loadAllUsers(users, photos);
        }

        public void OpenPrivateChat(string user, string otherUser)
        {
            // Get ID of PRIVATE chat of two users
            string querry = "SELECT GroupID FROM(" +
                        "SELECT Username, GroupID FROM Groups g JOIN UsersInGroups ug ON g.ID = ug.GroupID WHERE g.IsPrivateChat = 'True') SQ " +
                        "WHERE Username = '" + user + "' OR Username = '" + otherUser + "'  GROUP BY GroupID HAVING COUNT(*) > 1";

            string groupId = ConnC.ExecuteQuery(querry, 1).FirstOrDefault();

            if (groupId == null)
            {
                groupId = CreatePrivateChat(user, otherUser);
            }

            Clients.Caller.selectNewChat(groupId, otherUser);
        }

        private string CreatePrivateChat(string user, string otherUser)
        {
            var groupId = ConnC.ExecuteQuery("INSERT INTO Groups(IsPrivateChat) OUTPUT Inserted.ID VALUES('True')", 1).FirstOrDefault();
            InsertIntoGroup(groupId, user, Context.ConnectionId);
            Users other = ConnectedUsers.Where(u => u.UserName == otherUser).FirstOrDefault();
            InsertIntoGroup(groupId, otherUser, other!=null?other.ConnectionId:string.Empty);
            return groupId;
        }

        public void LoadAllUsers(string username)
        {
            var data = ConnC.ExecuteQuery("SELECT Username, Photo FROM Users WHERE Username <> '" + username + "'", 2);
            int count = data.Count;
            int j = 0;
            string[] users = new string[count / 2];
            string[] photos = new string[count / 2];
            for (int i = 0; i < count; i += 2)
            {
                users[j] = data[i];
                string path = data[i + 1];
                photos[j] = "images/DP/" + (path.Equals(string.Empty) ? "dummy.png" : path);
                j++;
            }

            Clients.Caller.loadAllUsers(users, photos);
        }

        public void LoadAllGroups(string username)
        {
            var data = ConnC.ExecuteQuery("SELECT Name, g.ID FROM Groups g JOIN UsersInGroups ug ON g.ID = ug.GroupID WHERE Username = '" + username + "'", 2);

            int count = data.Count;
            string[] groups = new string[count / 2];
            string[] ids = new string[count / 2];
            for (int i = 0; i < count/2; i++)
            {
                groups[i] = data[i*2];
                ids[i] = data[i * 2 + 1];
            }

            Clients.Caller.loadAllGroups(groups, ids);
        }

        public void SendPrivateMessage(string toUserId, string message)
        {

            string fromUserId = Context.ConnectionId;

            var toUser = ConnectedUsers.FirstOrDefault(x => x.ConnectionId == toUserId);
            var fromUser = ConnectedUsers.FirstOrDefault(x => x.ConnectionId == fromUserId);

            if (toUser != null && fromUser != null)
            {
                string CurrentDateTime = DateTime.Now.ToString();
                string UserImg = GetUserImage(fromUser.UserName);
                // send to 
                Clients.Client(toUserId).sendPrivateMessage(fromUserId, fromUser.UserName, message, UserImg, CurrentDateTime);

                // send to caller user
                Clients.Caller.sendPrivateMessage(toUserId, fromUser.UserName, message, UserImg, CurrentDateTime);
            }

        }
    }
}