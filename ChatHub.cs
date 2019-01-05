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
            }
        }

        public void SendMessageToAll(string userName, string message, string time)
        {
           string UserImg = GetUserImage(userName);

            // save message to database
            string query = "INSERT INTO Messages(Username,GroupID,Text,Time) VALUES('" + userName + "','" + 1 + "','" + message + "','" + time + "')";
            if (ConnC.ExecuteNonQuery(query) == 0)
            {
                return;
            }

            // store last 100 messages in cache
            AddMessageinCache(userName, message, time, UserImg);

            // Broad cast message
            Clients.All.messageReceived(userName, message, time, UserImg);
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

            }
            return base.OnDisconnected(stopCalled);
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