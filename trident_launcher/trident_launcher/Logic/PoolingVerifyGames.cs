using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using tridentCore;
using System.Diagnostics;


namespace trident_launcher_pooling
{
    internal class PoolingVerifyGames
    {
        

        public void initPooling()
        {
            PoolingCallback();
        }

        static void PoolingCallback()
        {
            while (true)
            {
                Process[] processes = Process.GetProcesses();
                // Coloque aqui o código que deseja executar a cada intervalo de tempo
                TridentCore tridentCore = new TridentCore();
                tridentCore.manipulateProcess(processes);
                Console.WriteLine("Classe chamada! Tempo atual: " + DateTime.Now);

                // Pausa de 30 segundos antes da próxima iteração
                Thread.Sleep(5000); // 30 segundos em milissegundos
            }
        }

    }
}
