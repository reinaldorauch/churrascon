-- Geração de Modelo físico
-- Sql ANSI 2003 - brModelo.
-- TODO, criar tablespaces e triggers

DROP DATABASE `churrascon`;

CREATE DATABASE `churrascon`
    DEFAULT CHARACTER SET 'utf8';

CREATE TABLE `churrascon`.`produto` (
    `id_produto` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `descricao` TEXT NOT NULL,
    `quantidade_estoque` DECIMAL(20 , 10 ) DEFAULT NULL
);

CREATE TABLE `churrascon`.`item_cotacao` (
    `id_item_cotacao` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `quantidade` DECIMAL(20 , 10 ) DEFAULT NULL,
    `valor_unitario` DECIMAL(12 , 2 ) DEFAULT NULL,
    `id_cotacao` BIGINT NOT NULL,
    `id_item_solicitacao` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`cotacao` (
    `id_cotacao` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `data_criacao` BIGINT NOT NULL DEFAULT 0,
    `status` CHAR(1) NOT NULL DEFAULT 'A', -- Tipos de status A = Andamento, Encerrado = Encerrado, C = Cancelado
    `id_cotacao_pai` BIGINT NULL,
    `id_solicitacao` BIGINT NOT NULL,
    `id_fornecedor` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`solicitacao` (
    `id_solicitacao` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `status` CHAR(1) NOT NULL DEFAULT 'A',
    `data_emissao` BIGINT NOT NULL DEFAULT 0,
    `data_expira` BIGINT NOT NULL DEFAULT 0,
    `id_cliente` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`fornecedor` (
    `id_fornecedor` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `cnpj` CHAR(14) NOT NULL,
    `id_pessoa` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`pessoa` (
    `id_pessoa` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `nome` VARCHAR(60) NOT NULL,
    `email` CHAR(100) NOT NULL
);

CREATE TABLE `churrascon`.`cliente` (
    `id_cliente` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `cpf` CHAR(11) NOT NULL,
    `limite_credito` DECIMAL(12 , 2 ) DEFAULT NULL,
    `id_pessoa` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`telefone` (
    `id_telefone` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `ddd` CHAR(2) NOT NULL,
    `numero` VARCHAR(20) NOT NULL,
    `tipo` CHAR(1) NOT NULL DEFAULT 'T',
    `id_pessoa` BIGINT NOT NULL
);

CREATE TABLE `churrascon`.`item_solicitacao` (
    `id_item_solicitacao` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `qtd` DECIMAL(20 , 10 ) DEFAULT NULL,
    `id_produto` BIGINT NOT NULL,
    `id_solicitacao` BIGINT NOT NULL
);

ALTER TABLE `churrascon`.`cliente`
	ADD FOREIGN KEY `cliente_pessoa` (`id_pessoa`)
    REFERENCES `churrascon`.`pessoa` (`id_pessoa`);

ALTER TABLE `churrascon`.`item_solicitacao`
    ADD FOREIGN KEY `item_solicitacao_produto` (`id_produto`)
    REFERENCES `churrascon`.`produto` (`id_produto`);

ALTER TABLE `churrascon`.`item_solicitacao`
    ADD FOREIGN KEY `item_solicitacao_solicitacao` (`id_solicitacao`)
    REFERENCES `churrascon`.`solicitacao` (`id_solicitacao`);

ALTER TABLE `churrascon`.`item_cotacao`
    ADD FOREIGN KEY `item_cotacao_cotacao` (`id_cotacao`)
    REFERENCES `churrascon`.`cotacao` (`id_cotacao`);

ALTER TABLE `churrascon`.`item_cotacao`
    ADD FOREIGN KEY `item_cotacao_item_solicitacao` (`id_item_solicitacao`)
    REFERENCES `churrascon`.`item_solicitacao` (`id_item_solicitacao`);

ALTER TABLE `churrascon`.`cotacao`
    ADD FOREIGN KEY `cotacao_solicitacao` (`id_solicitacao`)
    REFERENCES `churrascon`.`solicitacao` (`id_solicitacao`);

ALTER TABLE `churrascon`.`cotacao`
    ADD FOREIGN KEY `cotacao_fornecedor` (`id_fornecedor`)
    REFERENCES `churrascon`.`fornecedor` (`id_fornecedor`);

ALTER TABLE `churrascon`.`cotacao`
    ADD FOREIGN KEY `cotacao_cotacao_pai`(`id_cotacao_pai`)
    REFERENCES `churrascon`.`cotacao` (`id_cotacao`);

ALTER TABLE `churrascon`.`solicitacao`
    ADD FOREIGN KEY `solicitacao_cliente` (`id_cliente`)
    REFERENCES `churrascon`.`cliente` (`id_cliente`);

ALTER TABLE `churrascon`.`fornecedor`
    ADD FOREIGN KEY `fornecedor_pessoa` (`id_pessoa`)
    REFERENCES `churrascon`.`pessoa` (`id_pessoa`);

ALTER TABLE `churrascon`.`telefone`
	ADD FOREIGN KEY `telefone_pessoa` (`id_pessoa`)
	REFERENCES `churrascon`.`pessoa` (`id_pessoa`);

INSERT INTO `churrascon`.`produto` (`descricao`, `quantidade_estoque`) VALUES
	('Pernil Suíno', 0000005000),
	('Pernil Bovino', 0000002500),
	('Coca Cola', 0000004500);

INSERT INTO `churrascon`.`pessoa`
	(`nome`, `email`) VALUES
	('Reinaldo Antonio Camargo Rauch', 'reinaldorauch@gmail.com'),
	('Renann R. da Silva', 'renann.r.dasilva@facebook.com');

INSERT INTO `churrascon`.`telefone`
	(`ddd`,`numero`,`tipo`, `id_pessoa`) VALUES
	('42', '99933718', 'C', 1),
	('42', '84181733', 'C', 1);

INSERT INTO `churrascon`.`cliente`
	(`cpf`,`limite_credito`, `id_pessoa`) VALUES
	('05832920970', 10000000.00, 1);

INSERT INTO `churrascon`.`fornecedor`
	(`cnpj`, `id_pessoa`) VALUES
	('98831881000197', 2);

INSERT INTO `churrascon`.`solicitacao`
	(`data_emissao`, `data_expira`, `id_cliente`) VALUES
	(UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + 2 * 24 * 60 * 60, 1);

INSERT INTO `churrascon`.`item_solicitacao`
	(`qtd`, `id_produto`, `id_solicitacao`) VALUES
	(0000000020, 1, 1),
	(0000000010, 2, 1),
	(0000000005, 3, 1);

INSERT INTO `churrascon`.`cotacao`
	(`data_criacao`,`id_cotacao_pai`,`id_solicitacao`,`id_fornecedor`) VALUES
	(UNIX_TIMESTAMP(), NULL, 1, 1);

INSERT INTO `churrascon`.`item_cotacao`
	(`quantidade`,`valor_unitario`,`id_cotacao`,`id_item_solicitacao`) VALUES
	(0000000020, 0000000015.50, 1, 2),
	(0000000010, 0000000007.59, 1, 3),
	(0000000005, 0000000004.50, 1, 4);

--
-- Stored Procedures
--
DELIMITER //
CREATE PROCEDURE `churrascon`.`proc_neg_to_zero` (INOUT `field` DECIMAL(20,10)) LANGUAGE SQL
BEGIN
	IF `field` < 0 THEN
		SET `field` = 0;
	END IF;
END;//

CREATE PROCEDURE `churrascon`.`proc_text_less_three` (IN `field` TEXT) LANGUAGE SQL
BEGIN
	DECLARE msg VARCHAR(255);

	IF LENGTH(`field`) < 3 THEN
		SET msg = CONCAT('field cannot have less than three characters, data: ', `field`);
		SIGNAL SQLSTATE '45000' SET message_text = msg;
	END IF;
END;//

--
-- triggers
--

-- Triggers for table `produto`
DROP TRIGGER `ins_not_neg` //

CREATE TRIGGER `ins_not_neg` BEFORE INSERT ON `churrascon`.`produto`
FOR EACH ROW
BEGIN
	CALL `churrascon`.`proc_neg_to_zero`(new.`quantidade_estoque`);
	CALL `churrascon`.`proc_text_less_three` (new.`descricao`);
END;//

DROP TRIGGER `upt_not_neg` //

CREATE TRIGGER `upt_not_neg` BEFORE UPDATE ON `churrascon`.`produto`
FOR EACH ROW
BEGIN
	CALL `churrascon`.`proc_neg_to_zero`(new.`quantidade_estoque`);
	CALL `churrascon`.`proc_text_less_three` (new.`descricao`);
END;//

DELIMITER ;

--
-- Views
--

-- view para clientes
CREATE
    ALGORITHM = UNDEFINED
    DEFINER = `root`@`localhost`
    SQL SECURITY DEFINER
VIEW `vw_cliente` AS
    select
        `cliente`.`id_pessoa` AS `id_pessoa`,
        `cliente`.`id_cliente` AS `id_cliente`,
        `pessoa`.`nome` AS `nome`,
        `pessoa`.`email` AS `email`,
        `cliente`.`cpf` AS `cpf`,
        `cliente`.`limite_credito` AS `limite_credito`
    from
        (`pessoa`
        join `cliente` ON ((`pessoa`.`id_pessoa` = `cliente`.`id_pessoa`)));

-- View para usuários
CREATE
	ALGORITHM = UNDEFINED
	DEFINER = `root`@`localhost`
	SQL SECURITY DEFINER
VIEW `churrascon`.`vw_fornecedor` AS
SELECT
	`fornecedor`.`id_pessoa` AS `id_pessoa`,
	`fornecedor`.`id_cliente` AS `id_cliente`,
	`pessoa`.`nome` AS `nome`,
	`pessoa`.`email` AS `email`,
	`fornecedor`.`cnpj` AS `cnpj`
FROM (
	`churrascon`.`pessoa`
INNER JOIN
	`churrascon`.`fornecedor` ON ((`pessoa`.`id_pessoa` = `fornecedor`.`id_fornecedor`)));

-- View para vendas
SELECT
    *
FROM
    `churrascon`.`solicitacao` s
INNER JOIN
    `churrascon`.`cotacao` c ON s.`id_solicitacao` = c.`id_solicitacao`
INNER JOIN
    `churrascon`.`item_cotacao` ic ON c.`id_cotacao` = ic.`id_cotacao`
INNER JOIN
    `churrascon`.`item_solicitacao` `is` ON ic.`id_item_solicitacao` = `is`.`id_item_solicitacao`
WHERE
    s.`status` = 'E'
    AND c.`status` = 'E' -- Todas as cotações que estão encerradas

-- View para retornar a quantidade de cotações por solicitação
CREATE OR REPLACE VIEW `churrascon`.`vw_sol_qtd_cot` AS
SELECT
    c.id_solicitacao, count(id_cotacao) as qtd_cot
FROM
    cotacao c
GROUP BY c.id_solicitacao;

-- View para retornar as cotações que tem somente uma cotação atrelada
CREATE OR REPLACE VIEW `churrascon`.`vw_solicitacao_unique_cot` AS
SELECT
    s.*
FROM
    solicitacao s
INNER JOIN
    vw_sol_qtd_cot vwc ON s.id_solicitacao = vwc.id_solicitacao
WHERE
    vwc.qtd_cot = 1;

-- View para calcular o valor de cada cotação
CREATE OR REPLACE VIEW `churrascon`.`vw_valor_cotacao` AS
SELECT
    c.id_cotacao,
	c.id_solicitacao,
    SUM(ic.quantidade * valor_unitario) as valor
FROM
    cotacao c
        INNER JOIN
    item_cotacao ic ON c.id_cotacao = ic.id_cotacao
WHERE c.status = 'E'
GROUP BY
    c.id_cotacao;

-- view para calcular a cotação de menor valor
CREATE OR REPLACE VIEW `churrascon`.`vw_cotacao_menor_valor` AS
SELECT
    c.*,
    MIN(valor) AS valor
FROM
    vw_valor_cotacao vc
INNER JOIN
    cotacao c ON vc.id_cotacao = c.id_cotacao;
-- View para listar os produtos não cotados
CREATE OR REPLACE VIEW `vw_produtos_nao_cotados` AS
SELECT
    *
FROM
    `produto` `p`
WHERE
    `id_produto`
NOT IN (
    SELECT id_produto FROM vw_produtos_cotados
);

-- View para listar os produtos cotados
CREATE OR REPLACE VIEW `vw_produtos_cotados` AS
SELECT
    `is`.`id_produto`
FROM
    `item_cotacao` `ic`
INNER join
    `item_solicitacao` `is` ON `ic`.`id_item_solicitacao` = `is`.`id_item_solicitacao`
GROUP BY `is`.`id_produto`;

-- Select para selecionar o total cotado para cada cliente
CREATE OR REPLACE VIEW `vw_total_cotado_cliente` AS
SELECT
	p.nome as Cliente,
	SUM(vc.valor) as Valor
FROM
	cliente c
INNER JOIN
	solicitacao s ON c.id_cliente = s.id_cliente
INNER JOIN
	pessoa p ON c.id_pessoa = p.id_pessoa
INNER JOIN
	vw_valor_cotacao vc ON vc.id_solicitacao = s.id_solicitacao
GROUP BY c.id_cliente;

-- view para o total de cotações aprovadas ordenado pelo tal
CREATE OR REPLACE VIEW `vw_fornecedor_total_cotacao` AS
SELECT
	p.nome as Fornecedor,
	f.cnpj as CNPJ,
	COUNT(id_cotacao) as `Total de cotações aprovadas`
FROM
	fornecedor f
INNER JOIN
	pessoa p ON f.id_pessoa = p.id_pessoa
INNER JOIN
	cotacao c ON f.id_fornecedor = c.id_fornecedor
WHERE
	c.status = 'E'
GROUP BY f.id_fornecedor
ORDER BY `Total de cotações aprovadas`;

SELECT
	*
FROM
	solicitacao s
INNER JOIN
	item_solicitacao `is` ON s.id_solicitacao = `is`.id_solicitacao
INNER JOIN
	item_cotacao ic ON ic.id_item_solicitacao = `is`.id_item_solicitacao
INNER JOIN
	produto p ON `is`.id_produto = p.id_produto
INNER JOIN
	cotacao c ON c.id_cotacao = ic.id_cotacao
WHERE c.status = 'E' AND s.status = 'E';

-- View para retornar a quantidade de produtoas
CREATE OR REPLACE VIEW `vw_total_produto_solicitacao` AS
SELECT
	`is`.id_solicitacao,
	COUNT(`is`.id_produto) as total_produto
FROM
	item_solicitacao `is`
LEFT JOIN
	item_cotacao ic ON ic.id_item_solicitacao = `is`.id_item_solicitacao
INNER JOIN
	cotacao c ON c.id_cotacao = ic.id_cotacao
INNER JOIN
	solicitacao s ON s.id_solicitacao = `is`.id_solicitacao
WHERE c.status = 'E' AND s.status = 'E'
GROUP BY `is`.id_solicitacao;

-- View para contar a quantidade de produtos cadastrados no sistema
CREATE OR REPLACE VIEW `vw_total_produtos` AS
SELECT
	COUNT(id_produto) as total_produto
FROM produto;

-- View para verificar os clientes que tem uma solicitação com cotação aprovada com todos os produtos
CREATE OR REPLACE VIEW `vw_clientes_solicitacao_cotacao_aprovada_todos_produtos` AS
SELECT
	c.*
FROM
	cliente c
INNER JOIN
	solicitacao s ON c.id_cliente = s.id_cliente
INNER JOIN
	vw_total_produto_solicitacao tps ON s.id_solicitacao = tps.id_solicitacao
INNER JOIN
	vw_total_produtos tp ON tps.total_produto = tp.total_produto
GROUP BY id_cliente;

-- View para retornar a quantidade de cotacoes de uma solicitacao]
CREATE OR REPLACE VIEW `vw_total_cotacao` AS
SELECT
	s.id_solicitacao,
	COUNT(c.id_cotacao) as total_cotacao
FROM
	solicitacao s
INNER JOIN
	cotacao c ON s.id_solicitacao = c.id_solicitacao
GROUP BY s.id_solicitacao;

-- Select para retornar somente as solicitações com uma cotação
CREATE OR REPLACE VIEW `vw_solicitacao_unique_cotacao` AS
SELECT
	s.*
FROM
	solicitacao s
INNER JOIN
	vw_total_cotacao tc ON s.id_solicitacao = tc.id_solicitacao
WHERE tc.total_cotacao = 1;