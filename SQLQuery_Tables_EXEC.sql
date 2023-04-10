USE CampFutebol;
GO

CREATE TABLE Time (
    [apelido] VARCHAR(4) NOT NULL,
    [nome] VARCHAR(30) NOT NULL,
    [ano_cri] INT NOT NULL

    CONSTRAINT PK_Time PRIMARY KEY ([apelido])
)
GO

CREATE TABLE Campeonato (
    [nome] VARCHAR(20) NOT NULL,
    [num-equipes] INT NULL,
    [campeao] VARCHAR(4) NULL,
    [num_jogos] INT NULL

    CONSTRAINT PK_Campeonato PRIMARY KEY ([nome])
)
GO

CREATE TABLE Jogo (
    [time_Mand] VARCHAR(4) NOT NULL,
    [time_Visit] VARCHAR(4) NOT NULL,
    [nome_camp] VARCHAR(20) NOT NULL,
    [gol_Mand] INT NOT NULL,
    [gol_Visi] INT NOT NULL,

    CONSTRAINT PK_Jogo PRIMARY KEY ([time_Mand],[time_Visit],[nome_camp]),
    CONSTRAINT FK_Jogo_Campeonato FOREIGN KEY ([time_Mand],[nome_camp]) REFERENCES [InscreverCampeonato]([time],[campeonato]),
    CONSTRAINT FK_Jogo_TimeM FOREIGN KEY ([time_Visit], [nome_camp]) REFERENCES [InscreverCampeonato]([time],[campeonato]),
    CONSTRAINT CHK_TimeM CHECK (time_Mand <> time_Visit ) 
)
GO

DROP TABLE [Jogo]

CREATE TABLE InscreverCampeonato (
    [time] VARCHAR(4) NOT NULL,
    [campeonato] VARCHAR(20) NOT NULL,
    [pontos] INT NULL,
    [saldo_gols] INT NULL

    CONSTRAINT PK_InscrCamp PRIMARY KEY ([time],[campeonato])
    CONSTRAINT FK_InscrCamp_Time FOREIGN KEY ([time]) REFERENCES [Time]([apelido]),
    CONSTRAINT FK_InscrCamp_Campeonato FOREIGN KEY ([campeonato]) REFERENCES [Campeonato]([nome])
);
GO

--ORDEM ADICIONAR CAMPEONATO - [nome campeonato]
EXEC.USP_Inicio_Camp 'Brasileiro'

--ORDEM ADICIONAR TIME - [NOME],[SIGLA/APELIDO],[ANO CRIACAO]
EXEC.USP_AdicionarTime 'Piracicaba', 'PRF', 1985

--ORDEM INSCRICAO CAMPEONATO - [SIGLA/APELIDO TIME], [CAMPEONATO]
EXEC.USP_InncreverCampeonato 'SAN', 'Brasileiro'

--ORDEM INSERIR RESULTADO JOGO - [CAMPEONATO],[SIGLA/APELIDO CASA],[SIGLA/APELIDO VISITANTE],[GOL CASA],[GOL VISITANTE]
EXEC.USP_JogoCamp 'Brasileiro', 'COR', 'SAN', 1, 3

--EXIBICAO
SELECT * FROM [Campeonato]            --[Nome campeonato],[TCampeao],[Numero de euipes],[Numero de jogos]
SELECT * FROM [InscreverCampeonato]   --[Time],[Nome Campeonato],[Pontos],[Saldo de gols]
SELECT * FROM [Jogo]                  --[Time mandante],[Time visitante],[Nome campeonato],[Gol mandante],[Gol visitante]

UPDATE [Campeonato] SET [num_jogos] = 0

DELETE [Jogo] where [time_Mand] = 'COR'

--DELETAR
DELETE [InscreverCampeonato] WHERE [time] = 'SAN'




UPDATE [InscreverCampeonato] SET [saldo_gols] = null, [pontos] = null 