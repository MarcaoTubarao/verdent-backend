# BolsaBBB

Assistente de investimentos com backend em Python/Flask e frontend em Flutter.

## Estrutura

```
bolsa-bbb/
├── backend/          # API REST (Python/Flask)
│   ├── app.py        # Servidor principal
│   ├── config.py     # Configurações (lê do .env)
│   ├── scheduler.py  # Agendador de tarefas
│   ├── database.py   # Persistência
│   ├── models/       # Asset, Portfolio, Signal
│   ├── services/     # B3, Status Invest, Valuation, Scoring, Telegram
│   └── rules/        # Regras de compra/venda (Ações e FIIs)
│
└── frontend/         # App mobile (Flutter/Dart)
    └── lib/
        ├── models/   # Asset, Portfolio
        ├── services/ # ApiService
        ├── screens/  # Dashboard, Portfolio, Asset Detail
        └── widgets/  # Line Chart, Pie Chart
```

## Setup - Backend

### Pré-requisitos

- Python 3.10+
- pip

### Instalação

```bash
cd backend
pip install -r requirements.txt
```

### Configuração

Crie o arquivo `backend/.env`:

```
TELEGRAM_TOKEN=seu_token_aqui
TELEGRAM_CHAT_ID=seu_chat_id_aqui
```

### Executar

```bash
cd backend
python app.py
```

O servidor sobe em `http://127.0.0.1:5000`.

### Endpoints

| Rota          | Método | Descrição                  |
|---------------|--------|----------------------------|
| `/portfolio`  | GET    | Retorna total e rentabilidade |
| `/allocation` | GET    | Retorna alocação por tipo  |

## Setup - Frontend

### Pré-requisitos

- Flutter SDK 3.0+
- Dart SDK 3.0+

### Instalação

```bash
cd frontend
flutter pub get
```

### Configuração

Em `lib/services/api_service.dart`, altere `baseUrl` para o endereço do seu backend:

```dart
static const baseUrl = "http://SEU_BACKEND";
```

### Executar

```bash
cd frontend
flutter run
```

## Fluxo de Funcionamento

1. Backend coleta dados (B3 + Status Invest)
2. Calcula ROE, valuation e score do ativo
3. Gera sinal de compra/venda com base nas regras
4. Envia alerta via Telegram
5. Frontend consome a API e renderiza os gráficos
