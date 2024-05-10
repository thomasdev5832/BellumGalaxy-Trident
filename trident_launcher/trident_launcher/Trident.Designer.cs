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
            contextMenuStrip1 = new ContextMenuStrip(components);
            menuGroup = new GroupBox();
            LogonButton = new Button();
            initTrident = new Button();
            instructionText = new TextBox();
            textSaudationTrident = new TextBox();
            walletBox = new TextBox();
            menuGroup.SuspendLayout();
            SuspendLayout();
            // 
            // contextMenuStrip1
            // 
            contextMenuStrip1.Name = "contextMenuStrip1";
            contextMenuStrip1.Size = new Size(61, 4);
            // 
            // menuGroup
            // 
            menuGroup.AutoSize = true;
            menuGroup.Controls.Add(LogonButton);
            menuGroup.Controls.Add(initTrident);
            menuGroup.Controls.Add(instructionText);
            menuGroup.Controls.Add(textSaudationTrident);
            menuGroup.Location = new Point(1, -1);
            menuGroup.Name = "menuGroup";
            menuGroup.Size = new Size(995, 550);
            menuGroup.TabIndex = 7;
            menuGroup.TabStop = false;
            menuGroup.Enter += menuGroup_Enter;
            // 
            // LogonButton
            // 
            LogonButton.Location = new Point(915, 13);
            LogonButton.Name = "LogonButton";
            LogonButton.Size = new Size(66, 30);
            LogonButton.TabIndex = 9;
            LogonButton.Text = "Sair";
            LogonButton.UseVisualStyleBackColor = true;
            LogonButton.Click += LogonButton_Click;
            // 
            // initTrident
            // 
            initTrident.Location = new Point(415, 206);
            initTrident.Name = "initTrident";
            initTrident.Size = new Size(167, 73);
            initTrident.TabIndex = 7;
            initTrident.Text = "Iniciar";
            initTrident.UseVisualStyleBackColor = true;
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
            Name = "Trident";
            Text = "Trident";
            TransparencyKey = Color.Gray;
            Load += Form1_Load;
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
        private Button LogonButton;
    }
}
