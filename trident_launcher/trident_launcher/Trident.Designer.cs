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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Trident));
            contextMenuStrip1 = new ContextMenuStrip(components);
            LogonButton = new Button();
            textSaudationTrident = new TextBox();
            pictureBox1 = new PictureBox();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
            SuspendLayout();
            // 
            // contextMenuStrip1
            // 
            contextMenuStrip1.Name = "contextMenuStrip1";
            contextMenuStrip1.Size = new Size(61, 4);
            // 
            // LogonButton
            // 
            LogonButton.BackColor = Color.FromArgb(240, 0, 0, 0);
            LogonButton.FlatStyle = FlatStyle.Flat;
            LogonButton.ForeColor = SystemColors.Control;
            LogonButton.Location = new Point(916, 12);
            LogonButton.Name = "LogonButton";
            LogonButton.Size = new Size(66, 34);
            LogonButton.TabIndex = 9;
            LogonButton.Text = "Sair";
            LogonButton.UseVisualStyleBackColor = false;
            LogonButton.Click += LogonButton_Click;
            // 
            // textSaudationTrident
            // 
            textSaudationTrident.BackColor = SystemColors.WindowText;
            textSaudationTrident.BorderStyle = BorderStyle.None;
            textSaudationTrident.Font = new Font("Segoe UI", 12F);
            textSaudationTrident.ForeColor = SystemColors.MenuBar;
            textSaudationTrident.Location = new Point(12, 12);
            textSaudationTrident.Name = "textSaudationTrident";
            textSaudationTrident.ReadOnly = true;
            textSaudationTrident.Size = new Size(160, 22);
            textSaudationTrident.TabIndex = 7;
            textSaudationTrident.Text = "Bem vindo a Trident !";
            textSaudationTrident.TextChanged += textBox1_TextChanged;
            // 
            // pictureBox1
            // 
            pictureBox1.BackgroundImage = (Image)resources.GetObject("pictureBox1.BackgroundImage");
            pictureBox1.Location = new Point(1, -2);
            pictureBox1.Name = "pictureBox1";
            pictureBox1.Size = new Size(992, 542);
            pictureBox1.TabIndex = 10;
            pictureBox1.TabStop = false;
            // 
            // Trident
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.ButtonHighlight;
            BackgroundImageLayout = ImageLayout.Zoom;
            ClientSize = new Size(994, 540);
            Controls.Add(LogonButton);
            Controls.Add(textSaudationTrident);
            Controls.Add(pictureBox1);
            Name = "Trident";
            Text = "Trident";
            TransparencyKey = Color.Gray;
            Load += Form1_Load;
            ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
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
        private TextBox textSaudationTrident;
        private Button LogonButton;
        private PictureBox pictureBox1;
    }
}
