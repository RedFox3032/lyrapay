# LyraPay

P2P Wallet for the Libyan Market.

## Architecture

Clean Architecture with:
- Presentation (Riverpod + GoRouter)
- Domain (Entities + Use Cases)
- Data (Repositories + Data Sources)

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Copy `.env.development` to `.env` and fill in your Supabase credentials
4. Run `flutter run`

## Supabase Setup

1. Create a new Supabase project
2. Run the SQL schema from `supabase/migrations/001_initial_schema.sql`
3. Deploy Edge Functions from `supabase/functions/`

## Features

- Authentication (Email + Password)
- LyraTag claim
- Wallet with real-time balance
- P2P transfers
- Voucher redemption
- Activity feed
- Offline queue support
# lyrapay
