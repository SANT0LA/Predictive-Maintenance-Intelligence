-- ============================================================
-- Predictive Maintenance Intelligence
-- 03_failure_analysis.sql
-- Análise de falha por faixas de variáveis operacionais
-- ============================================================

-- 01. Falha por faixa de desgaste da ferramenta (Tool Wear)
-- Insight: efeito de limiar — taxa de falha estável (~2-3%) até 200min,
-- e salta para 15.4% acima disso. Sugere ponto de corte operacional.
SELECT
    CASE
        WHEN tool_wear BETWEEN 0   AND 50  THEN '0-50'
        WHEN tool_wear BETWEEN 51  AND 100 THEN '51-100'
        WHEN tool_wear BETWEEN 101 AND 150 THEN '101-150'
        WHEN tool_wear BETWEEN 151 AND 200 THEN '151-200'
        WHEN tool_wear BETWEEN 201 AND 253 THEN '201-253'
    END AS faixa_desgaste,
    COUNT(*) AS total,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY faixa_desgaste
ORDER BY faixa_desgaste;


-- 02. Falha por faixa de torque
-- Insight: padrão em "U" — risco mínimo na faixa 31-45 Nm (zona de operação
-- normal), disparando exponencialmente acima disso: 4.47% -> 17.41% -> 83.08%.
-- Consistente com falhas por sobrecarga mecânica (Overstrain Failure).
SELECT
    CASE
        WHEN torque BETWEEN 0     AND 30    THEN '0-30'
        WHEN torque BETWEEN 30.01 AND 45    THEN '31-45'
        WHEN torque BETWEEN 45.01 AND 55    THEN '46-55'
        WHEN torque BETWEEN 55.01 AND 65    THEN '56-65'
        WHEN torque BETWEEN 65.01 AND 76.6  THEN '66-76.6'
    END AS faixa_torque,
    COUNT(*) AS total,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY faixa_torque
ORDER BY faixa_torque;


-- 03. Falha por faixa de rotação (Rotational Speed)
-- Insight: padrão em "U" inverso ao torque — risco mais alto em rotações
-- baixas (22.69% abaixo de 1300 rpm), caindo para 0.51% na faixa 1501-1600
-- (zona de operação normal), voltando a subir levemente em rotações altas.
-- OBS: o valor mínimo real de rotational_speed nesse dataset é 1168, por
-- isso não existem registros abaixo de 1101 (faixa some do resultado).
SELECT
    CASE
        WHEN rotational_speed BETWEEN 0    AND 1100 THEN '0-1100'
        WHEN rotational_speed BETWEEN 1101 AND 1300 THEN '1101-1300'
        WHEN rotational_speed BETWEEN 1301 AND 1500 THEN '1301-1500'
        WHEN rotational_speed BETWEEN 1501 AND 1600 THEN '1501-1600'
        WHEN rotational_speed BETWEEN 1601 AND 2886 THEN '1601-2886'
    END AS faixa_rotacao,
    COUNT(*) AS total,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY faixa_rotacao
ORDER BY faixa_rotacao;


-- 04. Falha por combinação de faixas de torque x rotação
-- Cruzamento bivariado: revela duas zonas concentradas de risco que não
-- aparecem quando as variáveis são olhadas isoladamente (ver notebook de EDA).
SELECT
    CASE
        WHEN torque BETWEEN 0     AND 30    THEN '0-30'
        WHEN torque BETWEEN 30.01 AND 45    THEN '31-45'
        WHEN torque BETWEEN 45.01 AND 55    THEN '46-55'
        WHEN torque BETWEEN 55.01 AND 65    THEN '56-65'
        WHEN torque BETWEEN 65.01 AND 76.6  THEN '66-76.6'
    END AS faixa_torque,
    CASE
        WHEN rotational_speed BETWEEN 0    AND 1300 THEN '<=1300'
        WHEN rotational_speed BETWEEN 1301 AND 1600 THEN '1301-1600'
        WHEN rotational_speed BETWEEN 1601 AND 2886 THEN '>1600'
    END AS faixa_rotacao,
    COUNT(*) AS total,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY faixa_torque, faixa_rotacao
ORDER BY faixa_torque, faixa_rotacao;


-- 05. Falha por diferença de temperatura (Process - Air)
-- Insight: efeito de limiar — quando o gradiente térmico cai abaixo de 9K,
-- a taxa de falha salta para 8.52%, ~4x maior que nas demais faixas (~2%).
-- Consistente com falhas por dissipação de calor (Heat Dissipation Failure).
SELECT
    CASE
        WHEN (process_temperature - air_temperature) BETWEEN 7.6  AND 9    THEN '7.6-9'
        WHEN (process_temperature - air_temperature) BETWEEN 9.01 AND 9.5  THEN '9-9.5'
        WHEN (process_temperature - air_temperature) BETWEEN 9.51 AND 10   THEN '9.5-10'
        WHEN (process_temperature - air_temperature) BETWEEN 10.01 AND 10.5 THEN '10-10.5'
        WHEN (process_temperature - air_temperature) BETWEEN 10.51 AND 11  THEN '10.5-11'
        WHEN (process_temperature - air_temperature) BETWEEN 11.01 AND 12.1 THEN '11-12.1'
    END AS faixa_diff_temp,
    COUNT(*) AS total,
    SUM(machine_failure) AS falhas,
    ROUND(100.0 * SUM(machine_failure) / COUNT(*), 2) AS taxa_falha
FROM machine_data
GROUP BY faixa_diff_temp
ORDER BY faixa_diff_temp;
