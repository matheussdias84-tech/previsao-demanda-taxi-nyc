-- Standard SQL (Google BigQuery)
#1 - Filtragem de Regras de Negócio e Outliers: Consulta com apenas os registros consistentes de corridas válidas.
WITH corridas_validas AS (
  SELECT 
   *
  FROM `ds-psel-avaliacaotecnica.01.tabela`

  WHERE 
# Válidas as corridas que apresentarem de 1 a 4 passageiros
  passenger_count Between 1 AND 4
# Distância da viagem maior que zero
  AND trip_distance > 0 
#Valor total faturado maior que zero
  AND total_amount > 0
),
#Engenharia de Atributos Temporais: extrair os seguintes componentes de tempo a partir do campo pickup_datetime
corridas_com_features AS(
SELECT
  *,
#data consolidada, o ano, o mês, a hora do dia (número inteiro de 0 a 23) e o dia da semana (representado numericamente)
  EXTRACT(DATE FROM TIMESTAMP(pickup_datetime)) AS data_consolidada,
  EXTRACT(YEAR FROM TIMESTAMP(pickup_datetime)) AS ano,
  EXTRACT(MONTH FROM TIMESTAMP(pickup_datetime)) AS mes,
  EXTRACT(HOUR FROM TIMESTAMP(pickup_datetime)) AS hora,
  EXTRACT(DAYOFWEEK FROM TIMESTAMP(pickup_datetime)) AS dia_da_semana

FROM
  corridas_validas
)
SELECT
  data_consolidada,
  ano,
  mes,
  hora,
  dia_da_semana,
  pickup_location_id,

Count(1) AS total_viagens,
ROUND(SUM(total_amount), 2) AS faturamento_total,

FROM
  corridas_com_features
Group by
  data_consolidada,
  ano,
  mes,
  hora,
  dia_da_semana,
  pickup_location_id
  
Order by
  data_consolidada ASC,
  hora asc,
  pickup_location_id ASC;










