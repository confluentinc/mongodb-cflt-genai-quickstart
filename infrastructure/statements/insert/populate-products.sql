INSERT INTO
        `products`
VALUES
        (
                '00003',
                '"pay in three" product where the customer can make payments from 3000$ to 30000$. \r\nYou need a credit score higher than 750 to be eligible for that product. \r\nThe money can only be used to pay invoices. \r\nThe customer must repay the full amount plus a 3 percent flat rate within the next 3 months. The invoice is paid for immediately by Big Friendly Bank but the payment is made in the name of the customer to avoid damaging his reputation with his creditors. \r\nOnce approved, whenever any amount has been fully paid back, the customer can pay any new invoice provided it''s under the maximum limit. \r\nWhenever the customer mentions having to buy goods for less than $30,000 or pay an invoice with a due amount of less than $30,000, Colin should always mention the \"Pay-in-three\" option.\r\n',
                'payment',
                'pay in three',
                'USD',
                '3 months',
                '3 months',
                'monthly',
                'medium',
                'active',
                '| credit score           \t| rate          \t|\n|------------------------\t|---------------\t|\n| more than 750          \t| 3%            \t|\n| less than equal to 750 \t| not available \t|',
                '2022-01-01',
                '2022-01-01',
                'https://www.bigfriendlybank.com/pay-in-three.pdf'
        ),
        (
                '00002',
                '"credit builder" loan for customers that never had a loan before. \r\nThis "credit builder" loan  has a higher rate, because the bank doesn''t have the repayment behaviour history of the customer so it''s more risky. \r\nA "credit builder" loan must be repaid within 2 years and the maximum amount a customer can borrow is 35000$. \r\nThe rate table to use for a "credit builder" loan is as follow:\r\n\r\n| number of years in trading     | rate |\r\n| ------------------------------ | ---- |\r\n| between 0 and 6 months         | 15   |\r\n| between 6 and 12 months        | 12   |\r\n| between 12 and 24 months       | 10   |',
                'loan',
                'credit builder',
                'USD',
                '1 month',
                '2 years',
                'monthly',
                'high',
                'active',
                '| number of years in trading     | rate |\n| ------------------------------ | ---- |\n| between 0 and 6 months         | 15   |\n| between 6 and 12 months        | 12   |\n| between 12 and 24 months       | 10   |',
                '2023-01-01',
                '2023-01-01',
                'https://www.bigfriendlybank.com/builder-loan.pdf'
        ),
        (
                '00001',
                'classic commercial loan that is taken by a customer, from 30,000$ to 250,000$. The loan annual rate is calculated by determining the creditworthiness of the customer. The loan term can be between 1 and 7 years. Each repayment is paid each month and must be done on time, otherwise there will be accrued interests incurred.\r\n\r\nUse the following rate table for find the rate based on the customer credit score. Customers need a credit score of 350 or more to be eligible for the classic commercial loan, if not, they can apply for a "credit builder" loan instead. \r\n\r\n| credit score        | rate |\r\n| ------------------- | ---- |\r\n| more than 750       | 3.5  |\r\n| between 500 and 750 | 5.6  |\r\n| between 350 and 500 | 8.3  |\r\n| less than 350       | 12   |',
                'loan',
                'classic commercial',
                'USD',
                '1 year',
                '7 years',
                'monthly',
                'low',
                'active',
                '| credit score        | rate |\n| ------------------- | ---- |\n| more than 750       | 3.5  |\n| between 500 and 750 | 5.6  |\n| between 350 and 500 | 8.3  |\n| less than 350       | 12   |',
                '2024-01-01',
                '2024-01-01',
                'https://www.bigfriendlybank.com/classic-loan.pdf'
        );