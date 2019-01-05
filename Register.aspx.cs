using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SignalRChat
{
    public partial class Register : System.Web.UI.Page
    {
        ConnClass ConnC = new ConnClass();
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnRegister_ServerClick(object sender, EventArgs e)
        {
            string Query = "insert into Users(Username,Password)Values('"+txtUser.Value+"','"+txtPassword.Value+"')";
            string ExistQ = "select * from Users where Username='"+txtUser.Value+"'";
            if (!ConnC.IsExist(ExistQ))
            {
                if (ConnC.ExecuteNonQuery(Query) > 0)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "Message", "alert('Registration successful!');", true);
                    Session["UserName"] = txtUser.Value;
                    Response.Redirect("Chat.aspx");
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "Message", "alert('Username Already exists!');", true);
            }
        } 
    }
}