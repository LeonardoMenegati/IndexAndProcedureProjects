show databases;
use company;
show tables from company;

select * from departament;
select * from employee;


-----------------------------------------------------------------------------------------------------------------------------------------------------

															-- criando index

-- utilizado o hash pois existem poucos departamentos
CREATE INDEX index_departamento ON departament(dnumber) USING HASH;

-- utilizando btree pois existem muitos ids de funcionarios
CREATE INDEX index_funcionarios ON employee(ssn) USING BTREE;

-----------------------------------------------------------------------------------------------------------------------------------------------------

														-- Queries para as perguntas

-- Qual o departamento com maior número de pessoas?
select e.dno, d.dname, count(*) as quantidade from employee e, departament d
where e.dno = d.dnumber
group by d.dnumber
order by quantidade desc
LIMIT 1;

-- Quais são os departamentos por cidade?
select d.Dname, l.Dlocation from departament d, dep_locations l
where d.dnumber = l.dnumber
order by Dlocation;

-- Relação de empregrados por departamento
select e.ssn, concat(e.fname,'',e.lname) as nome_completo, d.dname, l.dlocation from employee e
inner join departament d on (e.dno = d.dnumber)
inner join dep_locations l on (d.dnumber = l.dnumber);

-----------------------------------------------------------------------------------------------------------------------------------------------------

												-- Criando Procedure
drop procedure ajuste_dependentes;
DELIMITER //

CREATE PROCEDURE ajuste_dependentes(
    IN Essn_p CHAR(9),
    IN Dependent_name_p VARCHAR(15),
    IN Sex_p CHAR(1),
    IN Bdate_p DATE,
    IN Relationship_p VARCHAR(8)
)
BEGIN
    -- Declaração de variável
    DECLARE Essn_existe INT;
    
    -- Verifica se o Essn já existe na tabela
    SELECT COUNT(*) INTO Essn_existe FROM dependent WHERE Essn = Essn_p;
    
    -- Verifica ação com base na existência do Essn
    
    IF Essn_existe = 1 AND (Relationship_p = 'Esposa' OR Relationship_p = 'Marido') THEN
        -- Se existe exatamente um registro e o relacionamento é 'Esposa' ou 'Marido', atualiza os dados
        UPDATE dependent SET Dependent_name = Dependent_name_p, Sex = Sex_p, Bdate = Bdate_p
        WHERE Essn = Essn_p AND (Relationship = 'Esposa' OR Relationship = 'Marido');
        SELECT * FROM dependent;
        
	ELSEIF Essn_existe >= 0 AND Essn_existe <= 3 THEN
        -- Insere um novo registro
        INSERT INTO dependent (Essn, Dependent_name, Sex, Bdate, Relationship)
        VALUES (Essn_p, Dependent_name_p, Sex_p, Bdate_p, Relationship_p);
        SELECT * FROM dependent;
    
    ELSEIF Essn_existe >= 3 THEN
        -- Se existem mais de 4 dependentes registros, remove todos os dependentes com esse Essn
        DELETE FROM dependent WHERE Essn = Essn_p;
        SELECT 'Dependentes removidos';
    
    END IF;
END //

DELIMITER ;



													-- Chamada da PROCEDURE
									-- (Essn_p, Dependent_name_p, Sex_p, Bdate_p, Relationship_p)

-- inserindo dados de dependentes para um funcionário 123454789 ainda não possui um salvo
call ajuste_dependentes ('123454789','Marido Um','M','1989-08-09','Marido');

-- update do conjuge do funcionário 123454789
call ajuste_dependentes ('123454789', 'Marido Dois','M','1989-08-01','Marido');

-- delete para funcionário com mais de 4 filhos
call ajuste_dependentes ('123456789', 'Filho Um','M','2000-01-09','Filho');
call ajuste_dependentes ('123456789', 'Filho Dois','F','2001-02-05','Filha');
call ajuste_dependentes ('123456789', 'Filho Três','M','1989-08-01','Filho');
call ajuste_dependentes ('123456789', 'Filho Quatro','M','1989-08-01','Filho');
-- aqui, os 4 filhos acima serão deletados
call ajuste_dependentes ('123456789', 'Filho Cinco', 'M', '2000-04-04','Filho');

-- consultar a tabela dependents
SELECT * FROM dependent;

-- remover todas as tuplas para refazer as chamadas da procedure acima.
delete from dependent
where Essn='123456789' or Essn= '123454789';