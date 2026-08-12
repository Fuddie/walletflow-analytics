"""Generate deterministic synthetic data for the WalletFlow portfolio project.

No real customer or transaction data is used.
"""

from __future__ import annotations

import csv
import random
from datetime import date, datetime, timedelta
from pathlib import Path

RANDOM_SEED = 42
CUSTOMER_COUNT = 250
TRANSACTION_COUNT = 5000

ROOT = Path(__file__).resolve().parents[1]
SEEDS = ROOT / "seeds"

FIRST_NAMES = ["Ada", "Tunde", "Chioma", "Yusuf", "Bola", "Ife", "Amina", "Kunle", "Zainab", "Emeka", "Sade", "David", "Mariam", "Femi", "Ngozi", "Ola", "Hauwa", "Chidi", "Temi", "Samuel"]
LAST_NAMES = ["Adeyemi", "Okafor", "Bello", "Eze", "Balogun", "Ibrahim", "Nwosu", "Adebayo", "Lawal", "Obi", "Ogunleye", "Musa", "Onyeka", "Salami", "Udo", "Ahmed", "Chukwu", "Afolayan", "Usman", "George"]
STATES = ["LA", "FC", "OY", "OG", "RV", "AN", "KN", "KD", "EN", "DE"]
SEGMENTS = ["STANDARD", "STANDARD", "STANDARD", "PREMIUM", "BUSINESS"]
WALLET_STATUSES = ["ACTIVE", "ACTIVE", "ACTIVE", "ACTIVE", "DORMANT", "SUSPENDED"]
TX_TYPES = ["transfer", "card_payment", "airtime", "bill_payment", "cash_in", "cash_out"]
MERCHANT_CATEGORIES = ["groceries", "transport", "utilities", "food", "ecommerce", "entertainment"]


def money(value: float) -> str:
    return f"{value:.2f}"


def main() -> None:
    random.seed(RANDOM_SEED)
    SEEDS.mkdir(parents=True, exist_ok=True)
    start_signup = date(2025, 1, 1)
    customers, wallets = [], []

    for i in range(1, CUSTOMER_COUNT + 1):
        cid, wid = f"C{i:05d}", f"W{i:05d}"
        first, last = random.choice(FIRST_NAMES), random.choice(LAST_NAMES)
        signup_date = start_signup + timedelta(days=random.randint(0, 365))
        customers.append({"customer_id": cid, "first_name": first, "last_name": last, "email": f"{first.lower()}.{last.lower()}.{i}@example.com", "state": random.choice(STATES), "customer_segment": random.choice(SEGMENTS), "signup_date": signup_date.isoformat(), "is_verified": random.random() < 0.92})
        wallet_created = datetime.combine(signup_date, datetime.min.time()) + timedelta(hours=random.randint(0, 72))
        wallets.append({"wallet_id": wid, "customer_id": cid, "created_at": wallet_created.strftime("%Y-%m-%d %H:%M:%S"), "wallet_status": random.choice(WALLET_STATUSES), "current_balance_ngn": money(max(0, random.gauss(65000, 80000)))})

    tx_start = datetime(2026, 1, 1, 8, 0, 0)
    transactions = []
    for i in range(1, TRANSACTION_COUNT + 1):
        customer_number = random.randint(1, CUSTOMER_COUNT)
        cid, wid = f"C{customer_number:05d}", f"W{customer_number:05d}"
        tx_type = random.choice(TX_TYPES)
        created_at = tx_start + timedelta(minutes=random.randint(0, 180 * 24 * 60))
        status_roll = random.random()
        status = "success" if status_roll < 0.88 else "failed" if status_roll < 0.97 else "reversed"
        base_amount = {"airtime": 2500, "bill_payment": 12000, "card_payment": 18000, "transfer": 30000, "cash_in": 40000, "cash_out": 25000}[tx_type]
        amount = max(100, random.lognormvariate(0.0, 0.8) * base_amount)
        fee = 0 if tx_type in {"airtime", "cash_in"} else min(500, max(10, amount * 0.005))
        completed_at = "" if status == "failed" else (created_at + timedelta(seconds=random.randint(2, 180))).strftime("%Y-%m-%d %H:%M:%S")
        merchant_category = random.choice(MERCHANT_CATEGORIES) if tx_type in {"card_payment", "bill_payment"} else ""
        transactions.append({"transaction_id": f"T{i:07d}", "wallet_id": wid, "customer_id": cid, "transaction_type": tx_type, "status": status, "amount_ngn": money(amount), "fee_ngn": money(fee), "merchant_category": merchant_category, "created_at": created_at.strftime("%Y-%m-%d %H:%M:%S"), "completed_at": completed_at})

    def write_csv(filename: str, rows: list[dict]) -> None:
        with (SEEDS / filename).open("w", newline="", encoding="utf-8") as handle:
            writer = csv.DictWriter(handle, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)

    write_csv("raw_customers.csv", customers)
    write_csv("raw_wallets.csv", wallets)
    write_csv("raw_transactions.csv", transactions)
    print(f"Generated {len(customers)} customers, {len(wallets)} wallets, and {len(transactions)} transactions.")


if __name__ == "__main__":
    main()
