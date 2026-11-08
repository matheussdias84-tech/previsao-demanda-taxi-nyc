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
#devido ao valor de R² anteriormente, ser -0,71, restringi para a top zonas para aumentar o volume de ids e melhor o valor de R²
  AND pickup_location_id IN (138,132,230,170,186,161,236,234,163,148)
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
#Agregação por Janela Temporal e Estação: dados por data, hora do dia e zona de embarque de interesse (pickup_location_id)
SELECT
  data_consolidada,
  ano,
  mes,
  dia_da_semana,
  hora,
  pickup_location_id,

Count(1) AS total_viagens,
ROUND(SUM(total_amount), 2) AS faturamento_total,

FROM
  corridas_com_features

Group by
  data_consolidada,
  ano,
  mes,
  dia_da_semana,
  hora,
  pickup_location_id

Order by
  data_consolidada ASC,
  hora ASC,
  pickup_location_id ASC,
  total_viagens ASC,
  faturamento_total ASC;
