# Behaviour

https://www.notion.so/how-to-describe-behaviour-1bea4df2eb114f76a659b3aa8b5336d5#164ec8080b9e420a8036d2f964f52fa1

# Model

```mermaid
classDiagram
    class Invoice {
        +Integer id
        +Integer organisation_id
        +Integer contact_id
        +String status
        +String currency_code
        +Date due_date
        +Money sub_total
        +LineItem[] line_items
        +Time deleted_at
        +Time created_at
        +Time updated_at
        <<Aggregate>>
    }
    class Organisation {
        +Integer id
        +String name
        +Time deleted_at
        +Time created_at
        +Time updated_at
        <<Aggregate>>
    }
    class Contact {
        +Integer id
        +Integer organisation_id
        +String first_name
        +String last_name
        +String email
        +Time deleted_at
        +Time created_at
        +Time updated_at
        <<Aggregate>>
    }
    class Money {
        +BigDecimal amount
        +String currency_code
        <<ValueObject>>
    }
    class LineItem {
        +Integer id
        +String description
        +Integer quantity
        +Money unit_amount
        <<Entity>>
    }

    Invoice "1" -- "1" Organisation : references
    Invoice "1" -- "1" Contact : references
    Contact "1" -- "1" Organisation : references
    Invoice "1" -- "1..*" LineItem : contains
```

# API

## Organisation

### Create

```
curl -X POST http://localhost:3000/accountify/organisation \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{"name": "New Organisation"}'
```

### Read

```
curl -X GET http://localhost:3000/accountify/organisation/1 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```

### Update

```
curl -X PUT http://localhost:3000/accountify/organisation/1 \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{"name": "Updated Organisation Name"}'
```

### Delete

```
curl -X DELETE http://localhost:3000/accountify/organisation/1 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```


## Contact

### Create

```
curl -X POST http://localhost:3000/accountify/contact \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{
           "organisation_id": 2,
           "first_name": "John",
           "last_name": "Doe",
           "email": "john.doe@example.com"
         }'
```

### Read

```
curl -X GET http://localhost:3000/accountify/contact/1 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```

### Update

```
curl -X PUT http://localhost:3000/accountify/contact/3 \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{
           "first_name": "Jane",
           "last_name": "Doe",
           "email": "jane.doe@example.com"
         }'
```

### Delete

```
curl -X DELETE http://localhost:3000/accountify/contact/3 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```


## Invoice

### Create

```
curl -X POST http://localhost:3000/accountify/invoice \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{
           "organisation_id": 2,
           "contact_id": 3,
           "currency_code": "AUD",
           "due_date": "2024-12-31",
           "line_items": [
             {
               "description": "Service Fee",
               "unit_amount": {"amount": 200, "currency_code": "AUD"},
               "quantity": 3
             },
             {
               "description": "Maintenance Fee",
               "unit_amount": {"amount": 150, "currency_code": "AUD"},
               "quantity": 5
             }
           ]
         }'
```

### Read

```
curl -X GET http://localhost:3000/accountify/invoice/1 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```

### Update

```
curl -X PUT http://localhost:3000/accountify/invoice/1 \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1" \
     -d '{
           "organisation_id": 2,
           "contact_id": 3,
           "due_date": "2025-01-31",  // New due date
           "line_items": [
             {
               "description": "Service Fee",
               "unit_amount": {"amount": 210, "currency_code": "AUD"},
               "quantity": 2  // Updated quantity
             },
             {
               "description": "Maintenance Fee",
               "unit_amount": {"amount": 150, "currency_code": "AUD"},
               "quantity": 4  // Updated quantity
             }
           ]
         }'

```

### Approve

```
curl -X PATCH http://localhost:3000/accountify/invoice/1/approve \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```

### Void

```
curl -X PATCH http://localhost:3000/accountify/invoice/1/void \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```

### Delete

```
curl -X DELETE http://localhost:3000/accountify/invoice/1 \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     -H "X-Iam-Tenant-id: 1"
```
