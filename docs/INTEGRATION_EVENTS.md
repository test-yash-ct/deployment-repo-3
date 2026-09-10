# Integration events

Application services emit typed domain events after successful writes so peers do not scrape HTTP APIs for side effects.

## Envelope

Every event uses the same JSON envelope:

```json
{
  "event_id": "uuid",
  "event_type": "...",
  "tenant_id": "...",
  "occurred_at": "RFC3339",
  "request_id": "...",
  "payload": {}
}
```

See `event-envelope.example.json` for a filled example. `payload` contains resource identifiers only (no PHI: names, notes, emails, phone numbers, or staff contact data).

## Event types

| Type | Producer | When | Payload keys |
|------|----------|------|----------------|
| `patient.updated` | patient-service | After a successful patient update | `patient_id` |
| `appointment.booked` | scheduling-service | After a successful book | `appointment_id`, `patient_id`, `provider_id` |
| `report.exported` | reporting-service | After a successful operational export | `export_id` |

## Transport

Transport is an **in-process outbox** in each service process (`Memory` implementation today). This is not a new message broker (no Kafka, SNS, or shared queue). A later dispatcher can drain the outbox and publish to a bus without changing producers.

Workloads that have adopted the outbox carry the Kubernetes Service label `healthops.io/events: outbox` (`patient-service` and `scheduling-service`). Reporting emits the same envelope in-process; the label can be added when that workload is rolled with the same contract.

Do not change Jenkins or Terraform for this contract.
