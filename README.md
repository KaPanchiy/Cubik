# Cubik — Jogo de Puzzle & Painel de Apoio e Segurança (PAP)

**Cubik** é uma aplicação móvel desenvolvida em Flutter para a Prova de Aptidão Profissional (PAP). A aplicação funciona como um jogo casual de blocos coloridos (estilo puzzle 8x8) que disfarça um painel confidencial de apoio e registo para vítimas de violência doméstica.

---

## 🎮 O Disfarce (Jogo Cubik)
À superfície, a aplicação é um jogo completo e funcional de puzzle de blocos:
- Tabuleiro 8x8 com colocação de peças, deteção de linhas/colunas completas e pontuação;
- **Boost 2x de Pontuação**: Código promocional `BLOCK2026` com limite de 3 utilizações diárias;
- **Renascimento**: Código de emergência `REVIVE` que limpa o centro do tabuleiro e permite continuar a partida após Game Over;
- **Sincronização Offline-First**: O High Score é guardado de imediato localmente e sincronizado em segundo plano com o Cloud Firestore (`users/{uid}/stats/game`).

---

## 🛡️ O Painel Oculto de Apoio
Acedido através do diálogo de "Resgatar Código" introduzindo o código secreto:
- **Primeiro Acesso**: Obriga o utilizador a definir um código secreto pessoal (mínimo 6 dígitos). O código de fábrica `1234` é permanentemente desativado;
- **Diário de Ocorrências**: Registo seguro de incidentes (data, título, categoria, gravidade e descrição);
- **Cifra AES-256**: Todas as descrições e registos locais são cifrados com chave criptográfica de 256 bits guardada no Keystore/Keychain do dispositivo via `flutter_secure_storage`. A chave é independente do PIN, prevenindo perda de dados ao alterar o código;
- **Sincronização Cloud Firestore**: Ocorrências sincronizadas em `users/{uid}/entries/{id}` com timestamp de auditoria de servidor (`createdAt` e `updatedAt`);
- **Botão "Sair Rápido"**: Limpa imediatamente toda a pilha de navegação (`popUntil`) e regressa ao jogo sem deixar registos na navegação;
- **Chamadas de Emergência Reais**: Botão "Ligar 112" e linhas de apoio (APAV 116 006, Linha de Apoio à Vítima 800 202 148, Emergência Social 144) com ligação direta ao discador nativo (`url_launcher`);
- **Proteção Contra Backups**: `android:allowBackup="false"` no `AndroidManifest.xml` para impedir que os dados confidenciais sejam extraídos via backup automático do Google Drive.

---

## 🔒 Arquitetura de Segurança
1. **PIN Hashed**: Apenas o hash `SHA-256` com sal (`cubik_pap_salt_sec_2026`) é guardado localmente. O PIN nunca é armazenado em texto limpo nem enviado para a nuvem.
2. **Cifra de Dados**: Cifra simétrica AES-256 em modo CBC com IV aleatório por registo (`EncryptionService`).
3. **Autenticação Anónima**: Utiliza `firebase_auth` anónimo para que a vítima nunca tenha de fornecer email, telefone ou dados pessoais identificáveis.
4. **Regras de Segurança Firestore**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

---

## 🧪 Testes Unitários
Para executar a suite de testes unitários:
```bash
flutter test
```
A suite inclui:
- Testes ao ciclo de vida e reset do tabuleiro 8x8 (`Board`);
- Testes ao limite diário e validação de códigos de boost (`BoostService`);
- Testes de cifra e decifra AES-256, incluindo rejeição de chaves incorretas (`EncryptionService`);
- Testes de validação e hashing de PIN (`SecretCodeService`);
- Testes de integridade das constantes de jogo (`GameCodes`).

---

## 🚀 Como Executar o Projeto
1. Instalar dependências:
   ```bash
   flutter pub get
   ```
2. Executar em modo Debug (Android / Chrome):
   ```bash
   flutter run
   ```
