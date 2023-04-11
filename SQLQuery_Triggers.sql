USE CAMPEONATOFUT;
GO

--TRIGGER PARA CONTABILIZAR O NUMERO DE JOGOS DO CAMPEONATO APOS INSERIR
CREATE OR ALTER TRIGGER TRG_NumJogo_Insert ON [Jogo] AFTER INSERT
AS
BEGIN
    DECLARE @numjogos INT, @nomecamp VARCHAR(20)
    SELECT @nomecamp = i.nome_camp FROM inserted i
    SELECT @numjogos = COUNT(jg.time_Mand) FROM [Jogo] jg, [Campeonato] c WHERE c.[nome] = @nomecamp
    UPDATE [Campeonato] SET [num_jogos] = @numjogos
END;
GO



--TRIGGER PARA CONTABILIZAR O NUMERO DE JOGOS DO CAMPEONATO APOS DELETAR
CREATE OR ALTER TRIGGER TRG_NumJogo_Delete ON [Jogo] AFTER DELETE
AS
BEGIN
    DECLARE @numjogos INT, @nomecamp VARCHAR(20)
    SELECT @nomecamp = d.nome_camp FROM deleted d
    SELECT @numjogos = COUNT(jg.time_Mand) FROM [Jogo] jg, [Campeonato] c WHERE c.[nome] = @nomecamp
    UPDATE [Campeonato] SET [num_jogos] = @numjogos
END;
GO

--TRIGGER PARA IMITAR O NÚMERO DE TIMES INSCRITOS NO CAMPEONATO
CREATE OR ALTER TRIGGER TRG_Num_Time_Camp ON [InscreverCampeonato] AFTER INSERT
AS
BEGIN
    DECLARE @nomecamp VARCHAR(20), @qnttime INT
    SELECT @nomecamp = i.campeonato FROM inserted i
    SELECT @qnttime = COUNT(ic.time) FROM InscreverCampeonato ic WHERE ic.campeonato = @nomecamp
    UPDATE [Campeonato] SET [num_equipes] = @qnttime WHERE [Campeonato].[nome] = @nomecamp
END;
GO

--TRIGGER PARA ATUALIZAR EQUIPES NO CAMPEONATO CASO DELETAR ALGUMA
CREATE OR ALTER TRIGGER TRG_Delete_Time_Camp ON [InscreverCampeonato] AFTER DELETE
AS
BEGIN
    DECLARE @nomecamp VARCHAR(20), @qnttime INT
    SELECT @nomecamp = d.campeonato FROM deleted d
    SELECT @qnttime = COUNT(ic.time) FROM InscreverCampeonato ic WHERE ic.campeonato = @nomecamp
    UPDATE [Campeonato] SET [num_equipes] = @qnttime WHERE [Campeonato].[nome] = @nomecamp
END;
GO

--TRIGGER ATUALIZAR PONTOS E SALDO DE GOLS APOS INSERIR JOGO (## PAREI AQUI ORDER BY TESTE ##)
CREATE OR ALTER TRIGGER TRG_Classific_Insert ON [Jogo] AFTER INSERT
AS
BEGIN
    UPDATE [InscreverCampeonato] SET [saldo_gols] = 0, [pontos] = 0 WHERE [saldo_gols] IS NULL AND [pontos] IS NULL
    UPDATE [InscreverCampeonato] SET [maiorgol] = 0 WHERE [maiorgol] IS NULL

    DECLARE @timemand VARCHAR(4), @timevisiti VARCHAR(4), @saldogolsm INT, @pontosm INT, @golm INT, 
            @golv INT, @saldogolsv INT, @pontosv INT, @maiorgolvisi INT, @maiorgolmand INT, @nomecamp VARCHAR(20), @anocamp INT
    SELECT @timemand = i.time_Mand, @timevisiti = i.time_Visit, @golm = i.gol_Mand, @golv = i.gol_Visi, @nomecamp = i.nome_camp,
           @anocamp = i.ano_camp  FROM inserted i
    SELECT @saldogolsm = ic.saldo_gols, @maiorgolmand = ic.maiorgol FROM [InscreverCampeonato] ic WHERE ic.time = @timemand
    SELECT @saldogolsv = ic.saldo_gols, @maiorgolvisi = ic.maiorgol FROM [InscreverCampeonato] ic WHERE ic.time = @timevisiti
    
    IF(@maiorgolmand < @golm)
        SET @maiorgolmand = @golm
    IF(@maiorgolvisi < @golv)
        SET @maiorgolvisi = @golv    

    SET @saldogolsm += (@golm - @golv) 
    SET @saldogolsv += (@golv - @golm)
    
    SET @pontosm = CASE WHEN (@golm > @golv) THEN 3 WHEN (@golm = @golv) THEN 1 ELSE 0 END 
    SET @pontosv = CASE WHEN (@golv > @golm) THEN 5 WHEN (@golv = @golm) THEN 1 ELSE 0 END

    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsm, [maiorgol] = @maiorgolmand WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsv, [maiorgol] = @maiorgolvisi WHERE [time] = @timevisiti
    UPDATE [InscreverCampeonato] SET [pontos] += @pontosm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [pontos] += @pontosv WHERE [time] = @timevisiti

END;
GO

--TRIGGER ATUALIZAR PONTOS E SALDO DE GOLS APOS DELETAR JOGO
CREATE OR ALTER TRIGGER TRG_Classific_Delete ON [Jogo] AFTER DELETE
AS
BEGIN
    DECLARE @timemand VARCHAR(4), @timevisiti VARCHAR(4), @saldogolsm INT, @pontosm INT, @golm INT, @golv INT, @saldogolsv INT, @pontosv INT
    SELECT @timemand = d.time_Mand, @timevisiti = d.time_Visit, @golm = d.gol_Mand, @golv = d.gol_Visi FROM deleted d
    SELECT @saldogolsm = ic.saldo_gols FROM [InscreverCampeonato] ic WHERE ic.time = @timemand
    SELECT @saldogolsv = ic.saldo_gols FROM [InscreverCampeonato] ic WHERE ic.time = @timevisiti
    DECLARE @golcomoMand INT, @golcomoVisit INT

    --BUSCA PARA VER O MAIOR GOL DE CADA EQUIPE DELETADA
    SELECT @golcomoMand = MAX(gol_Mand) FROM [Jogo] j WHERE j.[time_Mand] = @timemand 
    SELECT @golcomoVisit = MAX(gol_Visi) FROM [Jogo] j WHERE j.[time_Visit] = @timemand
    SELECT @golcomoMand = CASE WHEN (@golcomoMand IS NULL) THEN 0 ELSE @golcomoMand END
    SELECT @golcomoVisit = CASE WHEN (@golcomoVisit IS NULL) THEN 0 ELSE @golcomoVisit END
  
    IF(@golcomoMand > @golcomoVisit)
        UPDATE [InscreverCampeonato] SET [maiorgol] = @golcomoMand WHERE [time] = @timemand
    ELSE
    BEGIN
        UPDATE [InscreverCampeonato] SET [maiorgol] = @golcomoVisit WHERE [time] = @timemand
    END

    SELECT @golcomoMand = MAX(gol_Mand) FROM [Jogo] j WHERE j.[time_Mand] = @timevisiti
    SELECT @golcomoVisit = MAX(gol_Visi) FROM [Jogo] j WHERE j.[time_Visit] = @timevisiti
    SELECT @golcomoMand  = CASE WHEN (@golcomoMand IS NULL) THEN 0 ELSE @golcomoMand END
    SELECT @golcomoVisit = CASE WHEN (@golcomoVisit IS NULL) THEN 0 ELSE @golcomoVisit END
    IF(@golcomoMand > @golcomoVisit)
        UPDATE [InscreverCampeonato] SET [maiorgol] = @golcomoMand WHERE [time] = @timevisiti
    ELSE
    BEGIN
        UPDATE [InscreverCampeonato] SET [maiorgol] = @golcomoVisit WHERE [time] = @timevisiti
    END

    --DECREMENTA O SALDO DE GOLS
    SET @saldogolsm -= (@golm - @golv) 
    SET @saldogolsv -= (@golv - @golm)
    
    --VERIFICA PARA DECREMENTAR A PONTUACAO
    SET @pontosm = CASE WHEN (@golm > @golv) THEN 3 WHEN (@golm = @golv) THEN 1 ELSE 0 END 
    SET @pontosv = CASE WHEN (@golv > @golm) THEN 5 WHEN (@golv = @golm) THEN 1 ELSE 0 END

    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsv WHERE [time] = @timevisiti
    UPDATE [InscreverCampeonato] SET [pontos] -= @pontosm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [pontos] -= @pontosv WHERE [time] = @timevisiti
END;
GO

--DEFININDO CAMPEAO COM CRITERIO DE DESEMPATE
CREATE OR ALTER TRIGGER TRG_Campeao ON [InscreverCampeonato] AFTER UPDATE
AS
BEGIN
    DECLARE @numjogos INT, @nomecamp VARCHAR(20), @ano INT
    SELECT @numjogos = c.[num_jogos], @nomecamp = i.[campeonato], @ano = i.[ano_camp] FROM [Campeonato] c, inserted i
    WHERE c.[nome] = i.campeonato AND c.[ano] = i.ano_camp

    IF(@numjogos = 20)
    BEGIN
        DECLARE @maxpontos INT, @maxgols INT, @campeao VARCHAR(4)
        SELECT  @maxpontos = MAX([pontos]) FROM  [InscreverCampeonato] ic WHERE ic.[campeonato] = @nomecamp AND ic.[ano_camp] = @ano
        PRINT(@maxpontos)
        SELECT @maxgols = MAX(saldo_gols) FROM [InscreverCampeonato] ic WHERE ic.[pontos] = @maxpontos
        SELECT @campeao = ic.[time] FROM [InscreverCampeonato] ic WHERE ic.[pontos] = @maxpontos AND ic.[saldo_gols] = @maxgols

        UPDATE [Campeonato] SET [campeao] = @campeao WHERE [nome] = @nomecamp AND [ano] = @ano
    END
END;
GO