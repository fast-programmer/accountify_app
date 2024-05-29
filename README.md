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
