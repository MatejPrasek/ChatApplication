<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="SignalRChat.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
    <title>SignalR Chat : Register</title>
    <!-- Font Icon -->
    <link rel="stylesheet" href="fonts/material-icon/css/material-design-iconic-font.min.css"/>

    <!-- Main css -->
    <link rel="stylesheet" href="css/style.css"/>
</head>
<body>
<section class="sign-in">
            <div class="container">
                <div class="signin-content">
                    <div class="signin-image">
                        <figure><img src="images/login.png" alt="sing up image"/></figure>
                        <a href="Register.aspx" class="signup-image-link">Create an account</a>
                    </div>

                    <div class="signin-form">
                        <h2 class="form-title">Sign up</h2>
                        <form method="POST" class="register-form" id="form1" runat="server">
                            <div class="form-group">
                                <label for="txtUser"><i class="zmdi zmdi-account material-icons-name"></i></label>
                                <input type="text" id="txtUser" placeholder="Username" required="required" runat="server"/>
                            </div>
                            <div class="form-group">
                                <label for="txtPassword"><i class="zmdi zmdi-lock"></i></label>
                                <input type="password" id="txtPassword" placeholder="Password" required="required" runat="server"/>
                            </div>
                            <div class="form-group form-button">
                                <input type="submit" id="btnSignIn" runat="server" onserverclick="btnSignIn_Click" class="form-submit" value="Log in"/>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </section>
</body>
</html>
