USE CampFutebol;
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

--TRIGGER ATUALIZAR PONTOS E SALDO DE GOLS APOS INSERIR JOGO
CREATE OR ALTER TRIGGER TRG_Classific_Insert ON [Jogo] AFTER INSERT
AS
BEGIN
    UPDATE [InscreverCampeonato] SET [saldo_gols] = 0, [pontos] = 0 WHERE [saldo_gols] IS NULL AND [pontos] IS NULL

    DECLARE @timemand VARCHAR(4), @timevisiti VARCHAR(4), @saldogolsm INT, @pontosm INT, @golm INT, @golv INT, @saldogolsv INT, @pontosv INT
    SELECT @timemand = i.time_Mand, @timevisiti = i.time_Visit, @golm = i.gol_Mand, @golv = i.gol_Visi FROM inserted i
    SELECT @saldogolsm = ic.saldo_gols FROM [InscreverCampeonato] ic WHERE ic.time = @timemand
    SELECT @saldogolsv = ic.saldo_gols FROM [InscreverCampeonato] ic WHERE ic.time = @timevisiti
    PRINT(@timemand)
    PRINT(@timevisiti)
    SET @saldogolsm += (@golm - @golv) 
    SET @saldogolsv += (@golv - @golm)
    
    SET @pontosm = CASE WHEN (@golm > @golv) THEN 3 WHEN (@golm = @golv) THEN 1 ELSE 0 END 
    SET @pontosv = CASE WHEN (@golv > @golm) THEN 5 WHEN (@golv = @golm) THEN 1 ELSE 0 END

    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsv WHERE [time] = @timevisiti
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
    PRINT(@timemand)
    PRINT(@timevisiti)
    SET @saldogolsm -= (@golm - @golv) 
    SET @saldogolsv -= (@golv - @golm)
    
    SET @pontosm = CASE WHEN (@golm > @golv) THEN 3 WHEN (@golm = @golv) THEN 1 ELSE 0 END 
    SET @pontosv = CASE WHEN (@golv > @golm) THEN 5 WHEN (@golv = @golm) THEN 1 ELSE 0 END

    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [saldo_gols] = @saldogolsv WHERE [time] = @timevisiti
    UPDATE [InscreverCampeonato] SET [pontos] -= @pontosm WHERE [time] = @timemand
    UPDATE [InscreverCampeonato] SET [pontos] -= @pontosv WHERE [time] = @timevisiti
END;
GO