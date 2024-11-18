INSERT INTO all_insurance_products
    (SELECT CONCAT('car_', product_id) AS product_id,
            product_name,
            'car'                      AS product_type,
            coverage_type,
            repayment_frequency,
            rate_table,
            min_price,
            max_price,
            refLink,
            currency,
            createdAt
     FROM car_insurance_products)
UNION ALL
(SELECT CONCAT('home_', product_id) AS product_id,
        product_name,
        'home'                      AS product_type,
        coverage_type,
        repayment_frequency,
        rate_table,
        min_price,
        max_price,
        refLink,
        currency,
        createdAt
 FROM home_insurance_products);