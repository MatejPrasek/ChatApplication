﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs" Inherits="SignalRChat.Chat" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SignalR Chat : Chat Page</title>
    
    <%--<link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/css/bootstrap.min.css" rel="stylesheet"/>--%>
    <%--<script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.0/js/bootstrap.min.js"></script>--%>
<%--    <script src="//code.jquery.com/jquery-1.11.1.min.js"></script>--%>
    <!------ Include the above in your HEAD tag ---------->

    <link href="Content/bootstrap.min.css" rel="stylesheet" />
    <link href="Scripts/bootstrap.min.js" rel="stylesheet" />
    <link href="Content/style.css" rel="stylesheet" />
    <link href="Content/font-awesome.css" rel="stylesheet" />
    <link href="css/style.css" rel="stylesheet" />

    <script src="Scripts/jQuery-3.2.1.min.js"></script>
    <script src="Scripts/jquery.signalR-2.2.2.min.js"></script>
    <script src="Scripts/date.format.js"></script>
    <!--Reference the autogenerated SignalR hub script. -->
    <script src="signalr/hubs"></script>


    <script type="text/javascript">


        var IntervalVal;
        $(function () {

            // Declare a proxy to reference the hub.
           
            var chatHub = $.connection.chatHub;
            registerClientMethods(chatHub);
            // Start Hub
            $.connection.hub.start().done(function () {

                registerEvents(chatHub)

            });

            // Reset Message Counter on Hover
            $("#divChatWindow").mouseover(function () {

                $("#MsgCountMain").html('0');
                $("#MsgCountMain").attr("title", '0 New Messages');
            });

            // Diplay Image Preview on File Upload 
            $(document).on('change', '#<%= FileUpload1.ClientID%>', function (e) {

                var tmppath = URL.createObjectURL(e.target.files[0]);
                $("#ImgDisp").attr('src', tmppath);

            });

            // Stop Title Alert
            window.onfocus = function (event) {
                if (event.explicitOriginalTarget === window) {

                    clearInterval(IntervalVal);
                    document.title = 'SignalR Chat App';
                }
            }

        });

        // Show Title Alert
        function ShowTitleAlert(newMessageTitle, pageTitle) {
            if (document.title == pageTitle) {
                document.title = newMessageTitle;
            }
            else {
                document.title = pageTitle;
            }
        }

        function registerEvents(chatHub) {

            var name = '<%= this.UserName %>';
          
            if (name.length > 0) {
                chatHub.server.connect(name);

            }

            // Send Button Click Event
            $('#btnSendMsg').click(function () {

                var msg = $("#txtMessage").val().trim();

                if (msg.length > 0) {

                    var userName = $('#hdUserName').val();

                    var date = GetCurrentDateTime(new Date());

                    chatHub.server.sendMessageToAll(userName, msg, date);
                    $("#txtMessage").val('');
                }
            });

            // Send Message on Enter Button
            $("#txtMessage").keypress(function (e) {
                if (e.which == 13) {
                    $('#btnSendMsg').click();
                }
            });

             // Changing text of dropdown
            $(function () {
                $("#allUsers").click(function () {
                
                    $("#dropdownMenu2Text").text($(this).text());
                    $("#dropdownMenu2Text").val($(this).text());
                    chatHub.server.loadAllUsers(name);
               });

            });

            $(function () {
                $("#onlineUsers").click(function () {
                
                    $("#dropdownMenu2Text").text($(this).text());
                    $("#dropdownMenu2Text").val($(this).text());
                
               });

            });

            $(function () {
                $("#myGroups").click(function () {
                
                    $("#dropdownMenu2Text").text($(this).text());
                    $("#dropdownMenu2Text").val($(this).text());
                    chatHub.server.loadAllGroups(name);
               });

            });
        }

        function registerClientMethods(chatHub) {


            // Calls when user successfully logged in
            chatHub.client.onConnected = function (id, userName, allUsers, messages, times) {

                $('#hdId').val(id);
                $('#hdUserName').val(userName);
                $('#spanUser').html(userName);

                // Add All Users
                for (i = 0; i < allUsers.length; i++) {

                    AddUser(chatHub, allUsers[i].ConnectionId, allUsers[i].UserName, allUsers[i].UserImage, allUsers[i].LoginTime);
                }

                // Add Existing Messages
                for (i = 0; i < messages.length; i++) {
                    AddMessage(messages[i].UserName, messages[i].Message, messages[i].Time, messages[i].UserImage);

                }
            }

            // On New User Connected
            chatHub.client.onNewUserConnected = function (id, name, UserImage, loginDate) {
                AddUser(chatHub, id, name, UserImage, loginDate);
            }

            // On User Disconnected
            chatHub.client.onUserDisconnected = function (id, userName) {

                $('#li' + id).remove();

                var ctrId = 'private_' + id;
                $('#' + ctrId).remove();


                var disc = $('<div class="disconnect">"' + userName + '" disconnected.</div>');

                $(disc).hide();
                $('#divusers').prepend(disc);
                $(disc).fadeIn(200).delay(2000).fadeOut(200);

            }

            chatHub.client.messageReceived = function (userName, message, time, userimg) {

                AddMessage(userName, message, time, userimg);

                // Display Message Count and Notification
                var CurrUser1 = $('#hdUserName').val();
                if (CurrUser1 != userName) {

                    var msgcount = $('#MsgCountMain').html();
                    msgcount++;
                    $("#MsgCountMain").html(msgcount);
                    $("#MsgCountMain").attr("title", msgcount + ' New Messages');
                    var Notification = 'New Message From ' + userName;
                    IntervalVal = setInterval("ShowTitleAlert('SignalR Chat App', '" + Notification + "')", 800);

                }
            }


            chatHub.client.sendPrivateMessage = function (windowId, fromUserName, message, userimg, CurrentDateTime) {

                var ctrId = 'private_' + windowId;
                if ($('#' + ctrId).length == 0) {

                    OpenPrivateChatBox(chatHub, windowId, ctrId, fromUserName, userimg);

                }

                var CurrUser = $('#hdUserName').val();
                var Side = 'right';
                var TimeSide = 'left';

                if (CurrUser == fromUserName) {
                    Side = 'left';
                    TimeSide = 'right';

                }
                else {
                    var Notification = 'New Message From ' + fromUserName;
                    IntervalVal = setInterval("ShowTitleAlert('SignalR Chat App', '" + Notification + "')", 800);

                    var msgcount = $('#' + ctrId).find('#MsgCountP').html();
                    msgcount++;
                    $('#' + ctrId).find('#MsgCountP').html(msgcount);
                    $('#' + ctrId).find('#MsgCountP').attr("title", msgcount + ' New Messages');
                }

                var divChatP = '<div class="direct-chat-msg ' + Side + '">' +
                    '<div class="direct-chat-info clearfix">' +
                    '<span class="direct-chat-name pull-' + Side + '">' + fromUserName + '</span>' +
                    '<span class="direct-chat-timestamp pull-' + TimeSide + '"">' + CurrentDateTime + '</span>' +
                    '</div>' +

                    ' <img class="direct-chat-img" src="' + userimg + '" alt="Message User Image">' +
                    ' <div class="direct-chat-text" >' + message + '</div> </div>';

                $('#' + ctrId).find('#divMessage').append(divChatP);

                var htt = $('#' + ctrId).find('#divMessage')[0].scrollHeight;
                $('#' + ctrId).find('#divMessage').slimScroll({
                    height: htt
                });
            }

            
        
            chatHub.client.loadAllGroups = function (groups) {
                console.log("load all groups");
                console.log(groups);
            }


            chatHub.client.loadAllUsers = function (users, photos) {
                var div = document.getElementById("divusers");
                while (div.firstChild) {
                    div.removeChild(div.firstChild);
                }
                var i;
                for (i = 0; i < users.length; i++) {

                    code = $('<li class="left clearfix" id="li' + users[i] + '">' + 
                        '<span class="chat-img pull-left">' + 
                        '<img src="' + photos[i] + '" alt="User Avatar" class="img-circle img-sm">' +
                        '</span>' + 
                        '<div class="chat-body clearfix"> <div class="header_sec"> <strong class="primary-font">' + users[i] + '</strong>' +
                        '</div> </div></li>');

                    var UserLink = $('<a id="' + users[i] + '" class="user" >' + users[i] + '<a>');
                    $(code).click(function () {

                        var id = $(UserLink).attr('id');

                        OpenPrivateChatBox(chatHub, id, ctrId, name);

                    });

                    $("#divusers").append(code);
                }
            }
           
        }



        function GetCurrentDateTime(now) {

            var localdate = dateFormat(now, "yyyy-mm-dd HH:MM:ss");

            return localdate;
        }

        function AddUser(chatHub, id, name, UserImage, date) {

            var userId = $('#hdId').val();

            var code;
            if (userId == id) {
                return;
            }
            
            code = $('<li class="left clearfix" id="li' + id + '">' + 
                '<span class="chat-img pull-left">' + 
                '<img src="' + UserImage + '" alt="User Avatar" class="img-circle img-sm">' +
                '</span>' + 
                '<div class="chat-body clearfix"> <div class="header_sec"> <strong class="primary-font">' + name + '</strong>' +
                '<strong class="pull-right">' + 
                date + '</strong> </div> </div></li>');

            var UserLink = $('<a id="' + id + '" class="user" >' + name + '<a>');
            $(code).click(function () {

                var id = $(UserLink).attr('id');

                if (userId != id) {
                    var ctrId = 'private_' + id;
                    OpenPrivateChatBox(chatHub, id, ctrId, name);

                }

            });
            
            $("#divusers").append(code);

        }

        function AddMessage(userName, message, time, userimg) {

            var CurrUser = $('#hdUserName').val();
            var Side = 'right';
            var TimeSide = 'left';

            if (CurrUser !== userName) {
                Side = 'left';
                TimeSide = 'right';

            }

            var divChat = '<div class="direct-chat-msg ' + Side + '">' +
                '<div class="direct-chat-info clearfix">' +
                '<span class="direct-chat-name pull-' + Side + '">' + userName + '</span>' +
                '<span class="direct-chat-timestamp pull-' + TimeSide + '"">' + time + '</span>' +
                '</div>' +

                ' <img class="direct-chat-img" src="' + userimg + '" alt="Message User Image">' +
                ' <div class="direct-chat-text" >' + message + '</div> </div>';

            $('#divChatWindow').append(divChat);

            var height = $('#divChatWindow')[0].scrollHeight;
            $('#divChatWindow').scrollTop(height);

        }

        // Creation and Opening Private Chat Div
        function OpenPrivateChatBox(chatHub, userId, ctrId, userName) {

            var PWClass = $('#PWCount').val();

            if ($('#PWCount').val() == 'info')
                PWClass = 'danger';
            else if ($('#PWCount').val() == 'danger')
                PWClass = 'warning';
            else
                PWClass = 'info';

            $('#PWCount').val(PWClass);
            var div1 = ' <div class="col-md-4"> <div  id="' + ctrId + '" class="box box-solid box-' + PWClass + ' direct-chat direct-chat-' + PWClass + '">' +
                '<div class="box-header with-border">' +
                ' <h3 class="box-title">' + userName + '</h3>' +

                ' <div class="box-tools pull-right">' +
                ' <span data-toggle="tooltip" id="MsgCountP" title="0 New Messages" class="badge bg-' + PWClass + '">0</span>' +
                ' <button type="button" class="btn btn-box-tool" data-widget="collapse">' +
                '    <i class="fa fa-minus"></i>' +
                '  </button>' +
                '  <button id="imgDelete" type="button" class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button></div></div>' +

                ' <div class="box-body">' +
                ' <div id="divMessage" class="direct-chat-messages">' +

                ' </div>' +

                '  </div>' +
                '  <div class="box-footer">' +


                '    <input type="text" id="txtPrivateMessage" name="message" placeholder="Type Message ..." class="form-control"  />' +

                '  <div class="input-group">' +
                '    <input type="text" name="message" placeholder="Type Message ..." class="form-control" style="visibility:hidden;" />' +
                '   <span class="input-group-btn">' +
                '          <input type="button" id="btnSendMessage" class="btn btn-' + PWClass + ' btn-flat" value="send" />' +
                '   </span>' +
                '  </div>' +

                ' </div>' +
                ' </div></div>';



            var $div = $(div1);

            // Closing Private Chat Box
            $div.find('#imgDelete').click(function () {
                $('#' + ctrId).remove();
            });

            // Send Button event in Private Chat
            $div.find("#btnSendMessage").click(function () {

                $textBox = $div.find("#txtPrivateMessage");

                var msg = $textBox.val();
                if (msg.length > 0) {
                    chatHub.server.sendPrivateMessage(userId, msg);
                    $textBox.val('');
                }
            });

            // Text Box event on Enter Button
            $div.find("#txtPrivateMessage").keypress(function (e) {
                if (e.which == 13) {
                    $div.find("#btnSendMessage").click();
                }
            });

            // Clear Message Count on Mouse over           
            $div.find("#divMessage").mouseover(function () {

                $("#MsgCountP").html('0');
                $("#MsgCountP").attr("title", '0 New Messages');
            });

            // Append private chat div inside the main div
            $('#PriChatDiv').append($div);
        }


    </script>

</head>

<body>
<form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="content-wrapper">
        <div class="row">
           
            <div class="row">
                <div class="col-md-12">
                    <div class="row" id="PriChatDiv">
                    </div>
                    <textarea class="form-control" style="visibility: hidden;"></textarea>
                    <!--/.private-chat -->
                </div>
            </div>

            <!-- /.col -->


            <!-- /.col -->

            <!-- /.col -->
        </div>
        <!-- /.row -->
    </div>
    <span id="time"></span>
    <input id="hdId" type="hidden"/>
    <input id="PWCount" type="hidden" value="info"/>
    <input id="hdUserName" type="hidden"/>
    <div class="modal fade" id="ChangePic" role="dialog">
        <div class="modal-dialog" style="width: 700px">
            <div class="modal-content">
                <div class="modal-header bg-light-blue-gradient with-border">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Change Profile Picture</h4>
                </div>
                <div class="modal-body">
                    <div>
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <Triggers>
                                <asp:PostBackTrigger ControlID="btnChangePicModel"/>
                            </Triggers>
                            <ContentTemplate>
                                <div class="row">
                                    <div class="col-md-12">
                                        <table class="table table-bordered table-striped table-hover table-responsive" style="width: 600px">
                                            <tr>
                                                <div class="col-md-12">
                                                    <td class="text-primary col-md-4" style="font-weight: bold;">
                                                        <asp:FileUpload ID="FileUpload1" runat="server" class="btn btn-default"/>
                                                    </td>
                                                    <td class="col-md-4">
                                                        <asp:Button ID="btnChangePicModel" runat="server" Text="Update Picture" CssClass="btn btn-flat btn-success" OnClick="btnChangePicModel_Click"/>
                                                    </td>
                                                </div>
                                            </tr>
                                            <tr>
                                                <div class="col-md-12">
                                                    <td class="col-md-12" colspan="4"></td>
                                                </div>
                                            </tr>
                                        </table>
                                    </div>
                                </div>

                            </div>
                            </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="Scripts/bootstrap.min.js"></script>
<%--<script src="https://use.fontawesome.com/45e03a14ce.js"></script>--%>
<div class="main_section">
<div class="container">
<div class="chat_container">
<div class="col-sm-3 chat_sidebar">
    <div class="row">
        <div class="dropdown all_conversation">
            <button class="dropdown-toggle" type="button" id="dropdownMenu2" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <i class="fa fa-weixin" aria-hidden="true"></i>
                <span id="dropdownMenu2Text"> Online users </span>
                <span class="caret pull-right"></span>
            </button>
            <ul class="dropdown-menu" aria-labelledby="dropdownMenu2">
                <li>
                    <a href="#" id="onlineUsers"> Online users </a>
                </li>
                <li>
                    <a href="#" id="allUsers"> All users </a>
                </li>
                <li>
                    <a href="#" id="myGroups"> My groups </a>
                </li>
            </ul>
        </div>
        <ul class="list-unstyled">
        <div id="divusers" class="member_list">
        </div>
        </ul>
    </div>
</div>
<!--chat_sidebar-->
<div class="col-sm-9 message_section">
    <div class="row">
        <div class="new_message_head">
            <div class="pull-left">
                <button>
                    <i class="fa fa-plus-square-o" aria-hidden="true"></i> New Message
                </button>
            </div>
            <div class="pull-right">
                <div class="navbar-custom-menu">
                    <ul class="nav navbar-nav">
                        <!-- Messages: style can be found in dropdown.less-->

                        <!-- User Account: style can be found in dropdown.less -->
                        <li class="dropdown user user-menu">
                            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                                <img src="<%= UserImage %>" class="user-image" alt="User Image"/>
                                <span class="hidden-xs"><%= this.UserName %></span>
                            </a>
                            <ul class="dropdown-menu">
                                <!-- User image -->
                                <li class="user-header">
                                    <img src="<%= UserImage %>" class="img-circle" alt="User Image"/>
                                    <p style="color: #000000;">
                                        <%= UserName %>
                                    </p>
                                </li>
                                <!-- Menu Footer-->
                                <li class="user-footer">
                                    <div class="pull-left">
                                        <a class="btn btn-default btn-flat" data-toggle="modal" href="#ChangePic">Change Picture</a>
                                    </div>
                                    <div class="pull-right">
                                        <asp:Button ID="btnSignOut" runat="server" CssClass="btn btn-default btn-flat" Text="Sign Out" OnClick="btnSignOut_Click"/>
                                    </div>
                                </li>
                            </ul>
                        </li>
                        <!-- Control Sidebar Toggle Button -->
                    </ul>
                </div>
            </div>
        </div><!--new_message_head-->
        <div class="chat_area">
                <!-- Conversations are loaded here -->
                <div id="chat-box">
                    <!-- Conversations are loaded here -->
                    <div id="divChatWindow">
                    </div>
                    
                    <!-- /.direct-chat-pane -->
                </div>
        </div><!--chat_area-->

        <div class="message_write">
            <textarea id="txtMessage" class="form-control" placeholder="type a message"></textarea>
            <div class="clearfix"></div>
            <div class="chat_bottom">
                <a href="#" class="pull-right btn btn-success " id="btnSendMsg" >
                    Send</a>
            </div>
        </div>
    </div>
</div> <!--message_section-->
</div>
</div>
</div>
</form>
</body>
</html>
