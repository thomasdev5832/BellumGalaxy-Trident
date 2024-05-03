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
            button1 = new Button();
            SuspendLayout();
            // 
            // button1
            // 
            button1.BackColor = SystemColors.ButtonHighlight;
            button1.Location = new Point(273, 190);
            button1.Name = "button1";
            button1.Size = new Size(227, 52);
            button1.TabIndex = 0;
            button1.Text = "Iniciar";
            button1.UseVisualStyleBackColor = false;
            button1.Click += button1_Click;
            // 
            // Trident
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = SystemColors.ButtonHighlight;
            BackgroundImageLayout = ImageLayout.Zoom;
            ClientSize = new Size(800, 450);
            Controls.Add(button1);
            Name = "Trident";
            Text = "Trident";
            Load += Form1_Load;
            ResumeLayout(false);
        }

        private void button1_Click(object sender, EventArgs e)
{
            Process[] processes = Process.GetProcesses();

            TridentCore tridentCore = new TridentCore();
            string retorno = tridentCore.manipulateProcess(processes);

            // Cria uma instância do compilador C#

        }
        #endregion

        private Button button1;
    }
}
