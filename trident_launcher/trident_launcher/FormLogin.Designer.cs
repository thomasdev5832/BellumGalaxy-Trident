
namespace trident_launcher
{
    partial class FormLogin
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            GroupBox loginBox;
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormLogin));
            login = new Button();
            emailText = new TextBox();
            passwordText = new TextBox();
            password = new Label();
            Email = new Label();
            loginBox = new GroupBox();
            loginBox.SuspendLayout();
            SuspendLayout();
            // 
            // loginBox
            // 
            loginBox.AccessibleDescription = "Caixa para login";
            loginBox.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            loginBox.BackColor = Color.FromArgb(128, 0, 0, 100);
            loginBox.Controls.Add(login);
            loginBox.Controls.Add(emailText);
            loginBox.Controls.Add(passwordText);
            loginBox.Controls.Add(password);
            loginBox.Controls.Add(Email);
            loginBox.Location = new Point(324, 257);
            loginBox.Margin = new Padding(0);
            loginBox.Name = "loginBox";
            loginBox.Padding = new Padding(0);
            loginBox.Size = new Size(415, 279);
            loginBox.TabIndex = 7;
            loginBox.TabStop = false;
            loginBox.Enter += loginBox_Enter;
            loginBox.FlatStyle = FlatStyle.Flat; // Define o estilo do botão como Flat
            loginBox.FlatStyle = FlatStyle.Flat;
            loginBox.ForeColor = Color.FromArgb(0, 0, 0, 0);
            // 
            // login
            // 
            login.BackColor = Color.FromArgb(128, 0, 0, 100);
            login.ForeColor = Color.White;
            login.Location = new Point(122, 183);
            login.Name = "login";
            login.Size = new Size(149, 61);
            login.TabIndex = 4;
            login.Text = "Logar";
            login.UseVisualStyleBackColor = false;
            login.Click += login_Click;
            login.FlatStyle = FlatStyle.Flat; // Define o estilo do botão como Flat
            login.FlatAppearance.BorderSize = 0; // Remove a borda do botão
            login.BackColor = Color.FromArgb(128, Color.Black); // Define a opacidade para 50%
            login.ForeColor = Color.White;

            // 
            // emailText
            // 
            emailText.Location = new Point(64, 56);
            emailText.Name = "emailText";
            emailText.Size = new Size(289, 23);
            emailText.TabIndex = 0;
            // 
            // passwordText
            // 
            passwordText.Location = new Point(64, 112);
            passwordText.Name = "passwordText";
            passwordText.Size = new Size(289, 23);
            passwordText.TabIndex = 1;
            passwordText.UseSystemPasswordChar = true;
            // 
            // password
            // 
            password.AutoSize = true;
            password.ForeColor = Color.White;
            password.Location = new Point(61, 91);
            password.Name = "password";
            password.Size = new Size(39, 15);
            password.TabIndex = 3;
            password.Text = "Senha";
            // 
            // Email
            // 
            Email.AccessibleRole = AccessibleRole.None;
            Email.AutoSize = true;
            Email.ForeColor = Color.White;
            Email.Location = new Point(61, 35);
            Email.Name = "Email";
            Email.Size = new Size(36, 15);
            Email.TabIndex = 2;
            Email.Text = "Email";
            Email.Click += Email_Click;
            // 
            // FormLogin
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            BackColor = Color.MidnightBlue;
            BackgroundImage = (Image)resources.GetObject("$this.BackgroundImage");
            BackgroundImageLayout = ImageLayout.Center;
            ClientSize = new Size(1035, 679);
            Controls.Add(loginBox);
            Cursor = Cursors.No;
            ForeColor = SystemColors.ButtonHighlight;
            FormBorderStyle = FormBorderStyle.FixedSingle;
            Icon = (Icon)resources.GetObject("$this.Icon");
            Name = "FormLogin";
            RightToLeftLayout = true;
            ShowIcon = false;
            Text = "Login Trident";
            Load += FormLogin_Load;
            loginBox.ResumeLayout(false);
            loginBox.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private GroupBox loginBox;
        private Button login;
        private TextBox emailText;
        private TextBox passwordText;
        private Label password;
        private Label Email;
    }
}