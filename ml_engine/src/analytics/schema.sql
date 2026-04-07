-- [VM-32] Analytical Schema for StarRocks (Intelligent Wine Inventory)

-- Dimensions table: Item Information
CREATE TABLE IF NOT EXISTS dim_item (
    item_code VARCHAR(50) NOT NULL COMMENT "IF code or Wine code",
    description VARCHAR(255),
    variety VARCHAR(100),
    brand VARCHAR(100),
    presentation VARCHAR(100)
) ENGINE=OLAP
DISTRIBUTED BY HASH(item_code)
PROPERTIES ("replication_num" = "1");

-- Dimensions table: Customer Information
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id INT AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    market_type VARCHAR(50) COMMENT "Internal/External Market"
) ENGINE=OLAP
DISTRIBUTED BY HASH(customer_id)
PROPERTIES ("replication_num" = "1");

-- Fact table: Shipping Movements (Remitidos)
CREATE TABLE IF NOT EXISTS fact_shipped_moves (
    movement_id BIGINT AUTO_INCREMENT,
    issue_date DATE NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255),
    quantity_um1 DECIMAL(18, 2) COMMENT "Quantity in primary unit",
    quantity_um2 DECIMAL(18, 2) COMMENT "Quantity in secondary unit",
    document_code VARCHAR(20) COMMENT "Document code e.g. RT",
    point_of_sale INT
) ENGINE=OLAP
DUPLICATE KEY(movement_id, issue_date, item_code)
DISTRIBUTED BY HASH(item_code) BUCKETS 8
PROPERTIES ("replication_num" = "1");

-- Fact table: Inventory Snapshots
CREATE TABLE IF NOT EXISTS fact_inventory_snapshot (
    snapshot_date DATE NOT NULL,
    item_code VARCHAR(50) NOT NULL,
    warehouse_name VARCHAR(100),
    real_stock INT,
    net_stock INT
) ENGINE=OLAP
DUPLICATE KEY(snapshot_date, item_code)
DISTRIBUTED BY HASH(item_code) BUCKETS 8
PROPERTIES ("replication_num" = "1");
