USE CAMPEONATOFUT;
GO

--PROCEDURE PARA ADICIONAR CADASTRAR TIMES
CREATE OR ALTER PROCEDURE USP_Adicionar_Time @nome VARCHAR(30), @apelido VARCHAR(4), @anocri INT
AS 
BEGIN
    INSERT [Time]([nome], [apelido], [ano_cri]) VALUES (
        @nome, @apelido, @anocri
    )     
END;
GO

--PROCEDURE CADASTRANDO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Inicio_Camp @nome VARCHAR(20), @anocamp INT 
AS
BEGIN
    INSERT [Campeonato]([nome],[ano]) VALUES(
        @nome, @anocamp
    )
END;
GO

--PROCEDURE RELIZAR JOGOS DO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Jogo_Camp @nome_Camp VARCHAR(20), @anocamp INT,@timeM VARCHAR(4), @timeV VARCHAR(4), @golM INT, @golV INT
AS
BEGIN
    DECLARE @numjogos INT
    SELECT @numjogos = c.num_jogos FROM Campeonato c WHERE c.nome = @nome_Camp


    if(@numjogos < 20 OR @numjogos IS NULL)
        INSERT [Jogo] ([nome_camp], [ano_camp],[time_Mand], [time_Visit], [gol_Mand], [gol_Visi]) VALUES(
            @nome_Camp, @anocamp,@timeM, @timeV, @golM, @golV
        )
    ELSE
    BEGIN
        PRINT('Final de campeonato')    
    END    
END;
GO

--PROCEDURE PARA ADICIONAR TIMES AO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Inscrever_Campeonato @time VARCHAR(4), @camp VARCHAR(20), @anocamp INT
AS
BEGIN
    DECLARE @numtime INT
    SELECT @numtime = c.num_equipes FROM Campeonato c WHERE c.nome = @camp
    IF(@numtime < 5 OR @numtime IS NULL)
        INSERT [InscreverCampeonato]([time], [campeonato],[ano_camp]) VALUES (
            @time, @camp, @anocamp
        )
    ELSE
    BEGIN
        PRINT('Campeonato já atingiu limites de time.')
    END        
END;
GO


--PROCEDURE ESTATISTICAS FINAL CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Final_Campeonato @nomecamp VARCHAR(20), @anocamp INT
AS
BEGIN
    DECLARE @checkNumJogos INT
    SELECT @checkNumJogos = c.num_jogos FROM Campeonato c WHERE c.[nome] = @nomecamp AND c.[ano] = @anocamp
    IF(@checkNumJogos = 20)
    BEGIN
        DECLARE @campeao VARCHAR(4), @maisgols VARCHAR(4), @tomougols VARCHAR(4), @jogo VARCHAR(10)

        SELECT @campeao = c.[campeao] FROM Campeonato c WHERE c.[nome] = @nomecamp AND c.[ano] = @anocamp
        SELECT TOP 1 @maisgols = ic.[time] FROM [InscreverCampeonato] ic
            WHERE ic.[campeonato] = @nomecamp AND ic.[ano_camp]= @anocamp ORDER BY [saldo_gols] DESC
        SELECT top 1 @tomougols = ic.[time] FROM [InscreverCampeonato] ic
            WHERE ic.[campeonato] = @nomecamp AND ic.[ano_camp]= @anocamp ORDER BY [saldo_gols] ASC
        SELECT @jogo = j.[time_Mand] + ' x ' + [time_Visit] FROM [Jogo] j 
            WHERE j.[nome_camp] = @nomecamp AND j.[ano_camp] = @anocamp ORDER BY [gol_Mand] + [gol_Visi] ASC

        SELECT @campeao 'CAMPEAO', @maisgols 'MAIS FEZ GOLS', @tomougols 'MAIS TOMOU GOLS', 
            @jogo 'JOGO COM MAIS GOLS'
    END
    ELSE
    BEGIN
        PRINT('Campeonato nao encerrou.')
    END    
END;
GO

--PROCEDURE ANDAMENTO CAMPEONATO
CREATE OR ALTER PROCEDURE USP_Tabela_Campeonato @nomecamp VARCHAR(20), @anocamp INT
AS
BEGIN
    SELECT top 5 * FROM [InscreverCampeonato] ic WHERE ic.[campeonato] = @nomecamp AND ic.[ano_camp] = @anocamp ORDER BY [Pontos] DESC, 
    [saldo_gols] DESC
END;
GO