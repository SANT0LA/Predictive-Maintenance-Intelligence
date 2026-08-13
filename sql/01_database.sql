-- ============================================================
-- Predictive Maintenance Intelligence
-- 01_database.sql
-- Criação da estrutura do banco de dados
-- ============================================================

-- Criação do banco (rodar separadamente, fora de uma transação de tabela)
-- CREATE DATABASE predictive_maintenance;
-- \c predictive_maintenance

CREATE TABLE machine_data (
    udi                  INTEGER PRIMARY KEY,
    product_id           VARCHAR(20) NOT NULL,
    type                 CHAR(1) NOT NULL,
    air_temperature      NUMERIC(6,2) NOT NULL,
    process_temperature  NUMERIC(6,2) NOT NULL,
    rotational_speed     INTEGER NOT NULL,
    torque               NUMERIC(6,2) NOT NULL,
    tool_wear            INTEGER NOT NULL,
    machine_failure      SMALLINT NOT NULL,
    twf                  SMALLINT NOT NULL,
    hdf                  SMALLINT NOT NULL,
    pwf                  SMALLINT NOT NULL,
    osf                  SMALLINT NOT NULL,
    rnf                  SMALLINT NOT NULL
);

-- Conferir estrutura criada
-- \d machine_data

-- ============================================================
-- Importação dos dados (rodar via \copy no psql, client-side)
-- Espera um CSV sem colunas auxiliares de EDA (ex: soma_subtipos,
-- faixa_torque, faixa_rotacao etc.), apenas as 14 colunas originais,
-- na mesma ordem da tabela.
-- ============================================================

-- \copy machine_data(udi, product_id, type, air_temperature, process_temperature,
--     rotational_speed, torque, tool_wear, machine_failure, twf, hdf, pwf, osf, rnf)
-- FROM 'CAMINHO/PARA/data/processed/ai4i2020_sql.csv'
-- WITH (FORMAT csv, HEADER true);

-- Conferência pós-importação
-- SELECT COUNT(*) FROM machine_data;
