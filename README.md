# <p align="center"> TRIDENT

</p>

<p align="center"> Chainlink Block Magic Hackathon
</p>
</br>

<p align="center">
  <img src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjvVyyrK-60mygjEoVWPlaox2JNp_XS3eXWxOfFej7FUxpEfS6oU4O_GIdsUzgn1421NP5XGlxb8CmveXASq8k2XyF3eOyZ2FtbRNH6ma_QEF3sN6zsaNnDwipgEJDuYnOtSNdxPe5ON-1tV-ZDwVZBU1ZyMfGgEuWjg7KrBPcm2XAfnAifwOW5SXa7bX4/s320/trident-logo.png">
</p>
</br>

### Links
- Pitch deck video presentation is available on [YouTube](https://youtu.be/R5Az6V7_Q3c?si=U9Ybr6Tm4b0D6nBK)
- Live demo [website](https://bellumgalaxy-trident.vercel.app)
- [Slide](https://drive.google.com/file/d/1Us1ozLipa9OUPIwzb2qXpAkCL4ToqYBS/view?usp=sharing) presentation

</br>

### About Bellum Galaxy
We are an educational, scientific, and technological community, focused on breaking barriers and demystifying technology. Our mission is to empower individuals by providing learning and development opportunities, where contributions fuel innovation and drive positive change.

</br>

<p align="center">
  <img width="20%" src="https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDzC6qHOPXlQGVwQsz9J8IyLkIzbGDPkz08C7dzO06VeKkmluZJ0ollUVgwwvjteBLIPRn0BsZxJGr8S4Tfov7s5Oc8M8nxsTHa4VxamXvW5KGhXfbnVrkL5kESHmag0URch49nz0BTjGL3GbtqMXO0ULYhJbUSQfi2hmSNinyyUVmZyw_ZWBCpdRh5_Q/s16000/Logo-BG-1-semfundo.png">
</p>
</br>

Join us on [Discord](https://discord.com/invite/H2UpdzbbRJ) and together, we shape the future with blockchain technology.

</br>

### Summary

1. [Introduction]()
   
2. Trident Protocol

   2.1. The Prototype

3. Tools Used

   3.1. Chainlink VRF - Verifiable Random Function

   3.2. Chainlink CCIP - Cross-Chain Interoperability Protocol

   3.3. Chainlink Functions

   3.4. Chainlink Automation - Chainlink’s hyper-reliable Automation network

   3.5. [Chainlink Tools Summary Table]()

   3.6. API - Application Programming Interface

   3.7. Artificial Intelligence with OpenAI

4. Operation

5. Cost Projection

6. Evolution of the Protocol

7.  Conclusion

8. Developer Session

9. [Meet the Team]()

</br>

---

</br>

## Problem

- Primeiro relato de pirataria foi no século 17. Documento inglês que se referia à "piratas de palavras", ou seja, pessoas que copiavam conteúdo escrito indevidamente. [fonte](https://super.abril.com.br/mundo-estranho/por-que-usamos-o-termo-pirata-para-produtos-falsificados)
- Uma vez que investe na compra do jogo, independente do tempo que ele se dedique aquele jogo, esse investimento jamais será recuperado
- Ao decorrer do tempo e demanda, o valor dos jogos cai drasticamente e eventualmente deixam de ser realmente lucrativos.
- Alto custo de jogos.

## Solution

- Trident
  - NFT software. Uma vez que o nft é revendido a pessoa perde acesso à ele.
  - O software passa a ser propriedade do usuário. Onde ele poderá vende-lo eventualmente.
  - Bilhões de dólares são perdidos devido a pirataria. Além desses, outros bilhões ficam na mesa uma vez que o preço do software passa a declinar. Com a revenda, a desenvolvedora sempre terá uma fatia de qualquer venda.
  - Eliminando a pirataria, e todo o prejuízo que ela causa à industria, o valor dos softwares é diretamente influenciado positivamente. Com isso o preço é reduzido, tornando-os mais acessíveis a grande massa.
 
Valor arrecadado por Desenvolvedoras
  + Valor que era Perdido com Pirataria
    + -> Redução no Preço do Software
      + -> Aumento na Base de Clientes
        + -> Receita Extra vindo da Revenda.

### How we do

1. Pirataria
  - Tornando o acesso limitado através da chave de acesso, mesmo com a copia das dependências do jogo, não seria possível executá-lo. Logo, impossível de ser distribuído ilegalmente.
2. Jogador no Controle
  - Torna o jogo uma propriedade e permite que os jogadores, seus proprietários, comercializem seus ativos de modo à recuperar parte do seu investimento ou reinvestir em novos jogos.
3. Renda de longo prazo para desenvolvedoras.
  - A partir da possibilidade de venda, desenvolvedoras/distribuidoras receberão uma % do valor da revenda dos jogos e, por consequência, seus produtos continuarão rendendo no longo prazo.
4. Democratiza o acesso a jogos e consoles.
  - Através da eliminação da pirataria e da geração de renda contínua a partir do market, permite que as desenvolvedoras/distribuidoras reduzam sua margem e, por consequência, mais pessoas tenham acesso.

## Next steps
1. Implement improvements to reduce the cross-chain messaging time to users.
2. Implement a swapping functionality that allows users to buy using any Dex-tradable coin. However, receiving in specific stable.
3. Expand the proposal to other software, not only games.
4. Standardize the process to allow companies to incorporate it into existing infrastructure.

## Chainlink Tools Summary Table
### Chainlink Functions
|      Contract      |   Line   | Function               |   Go to  |
|--------------------|----------|------------------------|----------|
|TridentNFT.sol      |   278    | _update                | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/TridentNFT.sol#L278-L286)|
|TridentFunctions.sol|   83     | Whole contract         | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/main/SmartContracts/src/TridentFunctions.sol)|

### Chainlink CCIP
|      Contract       |   Line   | Function               |   Go to  |
|---------------------|----------|------------------------|----------|
|Trident.sol          |   278    | _sendMessage           | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/Trident.sol#L424-L450)|
|Trident.sol          |   278    | _ccipReceive           | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/Trident.sol#L334-L374)|
|CrossChainTrident.sol|   231    | _sendMessage           | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/CrossChainTrident.sol#L231-L278)|
|CrossChainTrident.sol|   288    | _ccipReceive           | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/CrossChainTrident.sol#L288-L306)|
|CrossChainTrident.sol|   83     | sendAdminMessage       | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/CrossChainTrident.sol#L169-L171)|

### Chainlink Automation
[Upkeep ID](100294353963328653549617203788371036649238998750535143727578973951519038272398).
|      Contract       |   Line   | Function               |   Go to  |
|---------------------|----------|------------------------|----------|
|Trident.sol          |    287   | gameScorerGetter       | [Check](https://github.com/BellumGalaxy/BlockMagic-Trident/blob/e96ca88b53d1dac287eb711b2696e322082fac18/SmartContracts/src/Trident.sol#L287-L300)|

## Technology
- Blockchain
  - Ethereum Sepolia
  - Optimism Sepolia
- Blockchain Primitives
  - NFT - ERC721
  - Stablecoin - ERC20
- Oráculos
  - Chainlink Functions
  - Chainlink CCIP
  - Chainlink Automation
- Programming Languages
  - Solidity
  - Python
  - Java Script
  - TypeScript
  - C#
- Frontend
  - React
  - Dynamic
  - Ethers.js
- Backend
  - API
  - Data Base
- Infrastructure
  - Launcher .exe
- Tools
  - Generative AI - OpenAI

## Meet the Team
|Name   | Title | Linkedin | X/Twitter | GitHub |     
|-------|-----------|----------|-----------|--------|
| Barba | Solidity Developer & Security Researcher | [Link](https://www.linkedin.com/in/i3arba/) | [Link](x.com/i3arba) | [Link](https://github.com/i3arba) |
| Raffa | Data Scientist & Blockchain Analyst | [Link](https://www.linkedin.com/in/raffaela-loffredo/) | [Link](https://twitter.com/loffredods) | [Link](https://github.com/raffaloffredo) |
| Gabriel | Crawler, Python, Node.js, C# Developer | [Link](https://www.linkedin.com/in/gabriel-muniz-schneider/) | - | [Link](https://github.com/dejazz) |
| Cayo | Frontend Developer | [Link](https://www.linkedin.com/in/cayo-morais-070b721b9/) | - | [Link](https://github.com/CayoTarcisio) |
| Gabriel | Full Stack Developer & Software Engineer | [Link](https://www.linkedin.com/in/gabrieltome/) | [Link](https://x.com/GabrielThomeDev) | [Link](https://github.com/thomasdev5832) |
