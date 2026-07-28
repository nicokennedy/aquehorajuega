# ¿A qué hora juega?

Aplicación Rails 7.1 con Ruby 3.3.7 y PostgreSQL.

## SEO e idiomas

- El host canónico es `https://aquehorajuega.pro`.
- Todo request público sin locale redirige permanentemente a `/es`.
- Inglés y portugués se conservan temporalmente con `noindex,follow`.
- Antes de reindexar `/en` o `/pt` deben traducirse por completo titles,
  descriptions, navegación, fechas, páginas de equipo, partido y competencia.

La redirección de `www` también existe dentro de Rails. En producción debe
configurarse además en el proxy/CDN o proveedor de hosting para que ocurra antes
de llegar a la aplicación. Ambos hosts deben conservar DNS y certificado TLS
válidos mientras exista la redirección.

## Sincronizaciones

Los endpoints internos encolan `PromiedosSyncJob`; no ejecutan scraping dentro
del request. El job:

- evita sincronizaciones concurrentes mediante un advisory lock de PostgreSQL;
- registra inicio, fin, duración, partidos procesados y errores en
  `synchronization_runs`;
- permite consultar el último éxito con
  `SynchronizationRun.last_successful_at("sync")`.

El adaptador `async` actual es una separación transitoria: no persiste jobs y
puede perder trabajo en reinicios o deploys. Antes de considerar esta cola
operativamente fiable en producción hay que instalar un backend persistente
compatible con Active Job, ejecutar al menos un proceso worker y configurar
reintentos/monitorización. No se agregó esa migración tecnológica en esta fase.

## Deploy

```sh
bin/rails db:migrate
bin/rails sitemap:refresh
```

## Integración con Football Tickets Argentina

La integración está apagada si `FOOTBALL_TICKETS_BASE_URL` no está definida.
Variables disponibles:

```sh
FOOTBALL_TICKETS_BASE_URL=https://ejemplo.com/entradas
FOOTBALL_TICKETS_TEAM_SLUGS=river-plate,boca-juniors
FOOTBALL_TICKETS_CTA_TEXT="Ver entradas"
FOOTBALL_TICKETS_UTM_SOURCE=aquehorajuega
FOOTBALL_TICKETS_UTM_MEDIUM=referral
FOOTBALL_TICKETS_UTM_CAMPAIGN=equipo_o_partido
```

Los enlaces sólo aparecen para partidos futuros de equipos habilitados. Se
marcan como `rel="sponsored"` y no afirman que exista stock.

## Calendarios

- `/:locale/teams/:slug/calendar.ics` descarga hasta 20 próximos partidos.
- `/:locale/games/:slug/calendar.ics` descarga un evento individual.

Los archivos son descargas puntuales, no suscripciones que se actualicen solas.

## Analítica

Los CTAs y enlaces clave exponen atributos `data-analytics-event`,
`data-analytics-source`, `data-analytics-team` y `data-analytics-game`. No se
instaló una dependencia de analítica; estos atributos permiten conectar GA4 u
otro proveedor posteriormente sin cambiar las vistas.

Después del deploy:

1. verificar los 301 de `www` y de las variantes `/today`;
2. configurar la redirección de host en hosting/CDN;
3. enviar `https://aquehorajuega.pro/sitemap.xml.gz` en Search Console;
4. comprobar que `/en` y `/pt` devuelven `noindex,follow`;
5. configurar un backend persistente y un worker antes de depender de los jobs.

## Tests

```sh
bundle exec rspec
bin/rails test
```
