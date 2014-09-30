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
    `status` CHAR(1) NOT NULL DEFAULT 'A',
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