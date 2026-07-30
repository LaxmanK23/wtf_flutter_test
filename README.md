## Security & Token Server Setup
 
1. Navigate to the server folder:
   ```bash
   cd shared/server
   ```
Create a local .env file based on the template:

```bash
cp .env.example .envs
```

Open .env and fill in your live 100ms HMS_ACCESS_KEY and HMS_SECRET. Never commit your .env file to version control.

Install dependencies and start the server:

```bash
npm install
node index.js
```

## Repo Build Instructions

To build and run both the Guru App and Trainer App from the root directory with a single workflow, follow these steps:

### 1. Run the Token Server

Open a terminal window, navigate to the local Node.js token server, install dependencies, and start the service:

```bash
cd shared/server
cp .env.example .env
```
Fill in your HMS_ACCESS_KEY and HMS_SECRET in .env


npm install
node index.js
2. Run the Guru App (Member)
Open a second terminal window, navigate to the Guru app directory, and launch:

```bash
cd guru_app
flutter pub get
flutter run
```

3. Run the Trainer App (Trainer)
   Open a third terminal window, navigate to the Trainer app directory, and launch:

```bash
cd trainer_app
flutter pub get
flutter run
```
