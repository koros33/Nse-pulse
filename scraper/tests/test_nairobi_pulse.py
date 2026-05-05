import importlib.util
from pathlib import Path
from datetime import date, timedelta

import pandas as pd

# Load scraper.py directly
_spec = importlib.util.spec_from_file_location(
    "scraper",
    Path(__file__).resolve().parent.parent / "scraper.py"
)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)
fetch_stock = _mod.fetch_stock

TODAY    = date.today()
ONE_WEEK = TODAY - timedelta(days=7)
TICKER   = "AAPL"

class TestNairobiPulse:

    def test_returns_data(self):
        df = fetch_stock(TICKER, ONE_WEEK, TODAY)
        assert not df.empty, "No data returned — check internet"

    def test_has_close_column(self):
        df = fetch_stock(TICKER, ONE_WEEK, TODAY)
        assert "Close" in df.columns

    def test_at_least_four_days(self):
        df = fetch_stock(TICKER, ONE_WEEK, TODAY)
        assert len(df) >= 4

    def test_positive_prices(self):
        df = fetch_stock(TICKER, ONE_WEEK, TODAY)
        closes = df["Close"].squeeze()
        assert bool((closes > 0).all())