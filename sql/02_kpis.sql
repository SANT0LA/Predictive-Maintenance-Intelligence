-- ============================================================
-- Predictive Maintenance Intelligence
-- 02_kpis.sql
-- KPIs gerais de negócio
-- ============================================================

-- 01. Taxa geral de falha
-- Resultado de referência: total_operacoes = 9973, total_falhas = 330, taxa_falha = 3.31%
SELECT
    COUNT(*) AS total_operacoes,
    SUM(machine_failure) AS total_falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data;


-- 02. Falha por tipo de máquina (L / M / H)
-- Insight: máquinas tipo L (baixa qualidade) falham proporcionalmente quase
-- 2x mais que máquinas tipo H (alta qualidade), mesmo em termos relativos.
-- Resultado de referência: L = 3.86% | M = 2.64% | H = 2.00%
SELECT
    type,
    COUNT(*) AS total_operacoes,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY type
ORDER BY taxa_falha DESC;
