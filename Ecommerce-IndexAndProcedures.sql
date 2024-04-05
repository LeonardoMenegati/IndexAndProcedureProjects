show databases;
use ecommerce;
show tables;

/* Recuperações simples com SELECT	*/						/* No Diagrama */
select * from tabela_clients;				-- tabela Cliente
select * from tabela_orders;				-- tabela Pedido
select * from tabela_productOrder;			-- tabela Produto/Pedido	(tabela vermelha diagrama)
select * from tabela_product;				-- tabela Produto
select * from tabela_storageLocation;		-- tabela Produto em Estoque (tabela vermelha diagrama)
select * from tabela_productStorage;		-- tabela Estoque
select * from tabela_productSupplier;		-- tabela Produto_fornecedor (tabela vermelha diagrama)
select * from tabela_Supplier;				-- tabela Fornecedor
select * from tabela_productSeller;			-- tabela Produto_vendedor Te (tabela vermelha diagrama)
select * from tabela_Seller;				-- tabela Terceiro - Vendedor
select * from tabela_payments;				-- tabela Pagamento

-----------------------------------------------------------------------------------------------------------------------------------------------------

															-- criando index

-- utilizado btree pois existem muitos produtos
CREATE INDEX index_produtos ON tabela_product(idProduct) USING BTREE;

-- utilizando btree pois existem muitos ids de clientes
CREATE INDEX index_clientes ON tabela_clients(idClient) USING BTREE;

-- utilizado btree pois existem muitos ids de pedidos
CREATE INDEX index_pedido ON tabela_orders(idOrder) USING BTREE;

-----------------------------------------------------------------------------------------------------------------------------------------------------

														-- Queries para as perguntas

-- Quais clientes da base de dados realizaram pedidos e quais produtos eles compraram? (INNER JOIN)
select concat(Fname,' ',Lname) as Nome_Completo, idOrder, Pname from tabela_clients
join tabela_orders on idClient = idOrderClient
join tabela_productOrder on idOrder = idPOorder
join tabela_product on idPOproduct = idProduct;

-- Quais fornecedores e vendedores tercerizados oferecem o mesmo produto? (INNER JOIN)
select Pname as Produto, idPproduct as Tercerizado, idPsProduct as Fornecedor from tabela_product
join tabela_productSupplier on idProduct =  idPsProduct
join tabela_Supplier on idPSsupplier = idSupplier
join tabela_productSeller on idProduct = idPproduct
join tabela_seller on idPseller = idSeller;

-- Qual a relação entre clientes e pedidos? (LEFT OUTER JOIN)
select idClient, concat(Fname,' ', Lname) as Nome_Completo, idOrder from tabela_clients
left outer join tabela_orders on idClient = idOrderClient;

-----------------------------------------------------------------------------------------------------------------------------------------------------

												-- Criando Procedure

DELIMITER //

CREATE PROCEDURE atualizacao_pedido(
    IN idOrder_p INT,
    IN idOrderClient_p int,
    IN orderStatus_p ENUM('Cancelado','Confirmado','Em processamento'),
    IN orderDescription_p VARCHAR(255),
    IN sendValue_p FLOAT,
    IN paymentCash_p TINYINT(1)
)
BEGIN
    -- Declaração de variável
    DECLARE Pedido_existe_p INT;
    
    -- Seleciona se existe ou não um idOrder na tabela_orders e a pesquisa é realizada através do idOrder_p passada na CALL pelo usuário 
    -- Se não existir, o count armazenará na variável Pedido_existe_p o valor 0. Se existir, armazenará o valor 1
    SELECT COUNT(*) INTO Pedido_existe_p FROM tabela_orders WHERE idOrder = idOrder_p;
    
    
    -- Verifica ação acima
    IF Pedido_existe_p = 0 THEN
		INSERT INTO tabela_orders (idOrder, idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)
        VALUES (idOrder_p, idOrderClient_p, orderStatus_p, orderDescription_p, sendValue_p, paymentCash_p);
        SELECT * FROM tabela_orders;
    
    ELSEIF Pedido_existe_p = 1 AND orderStatus_p = 'Confirmado' THEN
		UPDATE tabela_orders SET orderStatus = orderStatus_p
		WHERE idOrder = idOrder_p;
        SELECT * FROM tabela_orders;

	ELSEIF Pedido_existe_p = 1 AND orderStatus_p = 'Cancelado' THEN
        DELETE FROM tabela_orders WHERE idOrder = idOrder_p;
        SELECT 'Pedido cancelado';

    END IF;
END //

DELIMITER ;




													-- Chamada da PROCEDURE
						-- (idOrder, idOrderClient, orderStatus, orderDescription, sendValue, paymentCash)

-- UPDATE
CALL atualizacao_pedido ('100','1','Em processamento','Teste INSERT Procedure','100','1');
CALL atualizacao_pedido ('200','2','Em processamento','Teste UPDATE Procedure','200','1');		-- para o update
CALL atualizacao_pedido ('300','3','Em processamento','Teste DELETE Procedure','300','1');		-- para o delete

-- UPDATE
CALL atualizacao_pedido ('200','2','Confirmado','Teste UPDATE Procedure','200','1');

-- DELETE
CALL atualizacao_pedido ('300','3','Cancelado','Teste DELETE Procedure','300','1');




/*DELETE FROM tabela_orders
WHERE idOrder= '100';

DELETE FROM tabela_orders
WHERE idOrder= '200';*/