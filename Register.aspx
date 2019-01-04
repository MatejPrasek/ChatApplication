<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="SignalRChat.Register" %>

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
            <div class="container">
                <div class="signup-content">
                    <div class="signup-form">
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
                            <div class="form-group">
                                <label for="txtPasswordR"><i class="zmdi zmdi-lock-outline"></i></label>
                                <input type="password" id="txtPasswordR" placeholder="Repeat your password" required="required" runat="server"/>
                            </div>
                            <div class="form-group form-button">
                                <input type="submit" name="signup" class="form-submit" id="btnRegister" runat="server" onserverclick="btnRegister_ServerClick" value="Register"/>
                            </div>
                        </form>
                    </div>
                    <div class="signup-image">
                        <figure><img src="images/register.png" alt="sing up image"/></figure>
                        <a href="Login.aspx" class="signup-image-link">I am already member</a>
                    </div>
                </div>
            </div>

<script src="Scripts/bootstrap.min.js"></script>
</body>
</html>
