-- yindex: Equal-Weight Index Schema
-- Run with: psql -U postgres -d yindex -f db/schema.sql

-- ── Stocks ────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS stocks (
    id         SERIAL PRIMARY KEY,
    ticker     VARCHAR(20)  NOT NULL UNIQUE,
    name       VARCHAR(100) NOT NULL,
    active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Seed the 10 index constituents
INSERT INTO stocks (ticker, name) VALUES
    ('AAPL',  'Apple Inc'),
    ('MSFT',  'Microsoft Corporation'),
    ('GOOGL', 'Alphabet Inc'),
    ('AMZN',  'Amazon.com Inc'),
    ('META',  'Meta Platforms Inc'),
    ('TSLA',  'Tesla Inc'),
    ('NVDA',  'NVIDIA Corporation'),
    ('JPM',   'JPMorgan Chase'),
    ('V',     'Visa Inc'),
    ('JNJ',   'Johnson & Johnson')
ON CONFLICT (ticker) DO NOTHING;

-- ── Prices ───────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS prices (
    id          SERIAL PRIMARY KEY,
    stock_id    INTEGER     NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
    price_date  DATE        NOT NULL,
    close_price NUMERIC(12,4) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_stock_date UNIQUE (stock_id, price_date)
);

CREATE INDEX IF NOT EXISTS idx_prices_stock_date
    ON prices (stock_id, price_date DESC);

-- ── Index Values ──────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS index_values (
    id           SERIAL PRIMARY KEY,
    price_date   DATE           NOT NULL UNIQUE,
    index_value  NUMERIC(12,4)  NOT NULL,
    daily_change NUMERIC(8,4),
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_index_values_date
    ON index_values (price_date DESC);