
using tridentCore;
using System.Diagnostics;

namespace trident_launcher_pooling
{
    public class PoolingVerifyGames(string token)
    {
        public string token = token;

        public void initPooling()
        {
            PoolingCallback();
        }
        public void PoolingCallback()
        {
            while (true)
            {
                Process[] processes = Process.GetProcesses();
                // Coloque aqui o código que deseja executar a cada intervalo de tempo
                TridentCore tridentCore = new TridentCore(token);
                tridentCore.manipulateProcess(processes);
                Console.WriteLine("Classe chamada! Tempo atual: " + DateTime.Now);

                // Pausa de 30 segundos antes da próxima iteração
                Thread.Sleep(5000); // 30 segundos em milissegundos
            }
        }

    }
}
