using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SignalRChat
{
    public partial class Login : System.Web.UI.Page
    {
        //Class Object
        ConnClass ConnC = new ConnClass();
        protected void Page_Load(object sender, EventArgs e)
        {
           
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string Query = "select * from Users where Username='" + txtUser.Value + "' and Password='" + txtPassword.Value + "'";
            if (ConnC.IsExist(Query))
            {
                string UserName = ConnC.GetColumnVal(Query, "UserName");
                Session["UserName"] = UserName;
                Response.Redirect("Chat.aspx");
            }
            else
            {
                //todo error message
            }
        }
    }
}