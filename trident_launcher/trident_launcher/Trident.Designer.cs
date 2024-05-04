using System.Diagnostics;

using tridentCore;

namespace trident_launcher
{
    partial class Trident
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            emailText = new TextBox();
            passwordText = new TextBox();
            Email = new Label();
            password = new Label();
            login = new Button();
            contextMenuStrip1 = new ContextMenuStrip(components);
            loginBox = new GroupBox();
            menuGroup = new GroupBox();
            initTrident = new Button();
            instructionText = new TextBox();
            textSaudationTrident = new TextBox();
            walletBox = new TextBox();
            loginBox.SuspendLayout();
            menuGroup.SuspendLayout();
            SuspendLayout();
            // 
            // emailText
            // 
            emailText.Location = new Point(79, 56);
            emailText.Name = "emailText";
            emailText.Size = new Size(261, 23);
            emailText.TabIndex = 0;
            // 
            // passwordText
            // 
            passwordText.Location = new Point(79, 112);
            passwordText.Name = "passwordText";
            passwordText.Size = new Size(261, 23);
            passwordText.TabIndex = 1;
            passwordText.UseSystemPasswordChar = true;
            // 
            // Email
            // 
            Email.AccessibleRole = AccessibleRole.None;
            Email.AutoSize = true;
            Email.Location = new Point(79, 38);
            Email.Name = "Email";
            Email.Size = new Size(36, 15);
            Email.TabIndex = 2;
            Email.Text = "Email";
            // 
            // password
            // 
            password.AutoSize = true;
            password.Location = new Point(79, 94);
            password.Name = "password";
            password.Size = new Size(39, 15);
            password.TabIndex = 3;
            password.Text = "Senha";
            // 
            // login
            // 
            login.Location = new Point(124, 177);
            login.Name = "login";
            login.Size = new Size(149, 61);
            login.TabIndex = 4;
            login.Text = "Logar";
            login.UseVisualStyleBackColor = true;
            login.Click += login_Click;
            // 
            // contextMenuStrip1
            // 
            contextMenuStrip1.Name = "contextMenuStrip1";
            contextMenuStrip1.Size = new Size(61, 4);
            // 
            // loginBox
            // 
            loginBox.Controls.Add(login);
            loginBox.Controls.Add(emailText);
            loginBox.Controls.Add(passwordText);
            loginBox.Controls.Add(password);
            loginBox.Controls.Add(Email);
            loginBox.Location = new Point(254, 132);
            loginBox.Name = "loginBox";
            loginBox.Size = new Size(412, 279);
            loginBox.TabIndex = 6;
            loginBox.TabStop = false;
            // 
            // menuGroup
            // 
            menuGroup.AutoSize = true;
            menuGroup.Controls.Add(initTrident);
            menuGroup.Controls.Add(instructionText);
            menuGroup.Controls.Add(textSaudationTrident);
            menuGroup.Location = new Point(1, 2);
            menuGroup.Name = "menuGroup";
            menuGroup.Size = new Size(995, 537);
            menuGroup.TabIndex = 7;
            menuGroup.TabStop = false;
            menuGroup.Visible = false;
            menuGroup.Enter += menuGroup_Enter;
            // 
            // initTrident
            // 
            initTrident.Location = new Point(415, 206);
            initTrident.Name = "initTrident";
            initTrident.Size = new Size(167, 73);
            initTrident.TabIndex = 7;
            initTrident.Text = "Iniciar";
            initTrident.UseVisualStyleBackColor = true;
            initTrident.Visible = false;
            initTrident.Click += initTrident_Click;
            // 
            // instructionText
            // 
            instructionText.BorderStyle = BorderStyle.None;
            instructionText.Location = new Point(360, 142);
            instructionText.Multiline = true;
            instructionText.Name = "instructionText";
            instructionText.Size = new Size(277, 31);
            instructionText.TabIndex = 8;
            instructionText.Text = "Para iniciar o App clique em Iniciar!";
            instructionText.TextAlign = HorizontalAlignment.Center;
            instructionText.TextChanged += textBox2_TextChanged_1;
            // 
            // textSaudationTrident
            // 
            textSaudationTrident.BorderStyle = BorderStyle.None;
            textSaudationTrident.Font = new Font("Segoe UI", 12F);
            textSaudationTrident.Location = new Point(0, 0);
            textSaudationTrident.Name = "textSaudationTrident";
            textSaudationTrident.Size = new Size(160, 22);
            textSaudationTrident.TabIndex = 7;
            textSaudationTrident.Text = "Bem vindo a Trident !";
            textSaudationTrident.TextChanged += textBox1_TextChanged;
            // 
            // walletBox
            // 
            walletBox.BorderStyle = BorderStyle.None;
            walletBox.Location = new Point(823, 12);
            walletBox.Name = "walletBox";
            walletBox.Size = new Size(131, 16);
            walletBox.TabIndex = 9;
            // 
            // Trident
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.ButtonHighlight;
            BackgroundImageLayout = ImageLayout.Zoom;
            ClientSize = new Size(994, 540);
            Controls.Add(menuGroup);
            Controls.Add(walletBox);
            Controls.Add(loginBox);
            Name = "Trident";
            Text = "Trident";
            TransparencyKey = Color.Gray;
            Load += Form1_Load;
            loginBox.ResumeLayout(false);
            loginBox.PerformLayout();
            menuGroup.ResumeLayout(false);
            menuGroup.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button initApp;
        private TextBox emailText;
        private TextBox passwordText;
        private Label Email;
        private Label password;
        private Button login;
        private ContextMenuStrip contextMenuStrip1;
        private GroupBox loginBox;
        private Button initTrident;
        private GroupBox menuGroup;
        private TextBox textSaudationTrident;
        private TextBox instructionText;
        private TextBox walletBox;
    }
}
