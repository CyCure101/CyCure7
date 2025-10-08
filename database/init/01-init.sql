USE cycure_quiz;

CREATE TABLE IF NOT EXISTS users
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    username   VARCHAR(50) UNIQUE  NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    password   VARCHAR(255)        NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quizzes
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    module_type     ENUM ('Customer Service', 'IT-Security', 'General') NOT NULL,
    title           VARCHAR(200)                                        NOT NULL,
    description     TEXT,
    total_questions INT       DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS questions
(
    id            INT PRIMARY KEY AUTO_INCREMENT,
    quiz_id       INT  NOT NULL,
    question_text TEXT NOT NULL,
    question_type ENUM ('multiple_choice') DEFAULT 'multiple_choice',
    FOREIGN KEY (quiz_id) REFERENCES quizzes (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS answers
(
    id           INT PRIMARY KEY AUTO_INCREMENT,
    question_id  INT  NOT NULL,
    answer_text  TEXT NOT NULL,
    is_correct   BOOLEAN DEFAULT FALSE,
    answer_order INT  NOT NULL CHECK (answer_order BETWEEN 1 AND 4),
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_attempts
(
    id              INT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT NOT NULL,
    quiz_id         INT NOT NULL,
    score           INT       DEFAULT 0,
    total_questions INT       DEFAULT 0,
    completed_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (quiz_id) REFERENCES quizzes (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_responses
(
    id                 INT PRIMARY KEY AUTO_INCREMENT,
    attempt_id         INT NOT NULL,
    question_id        INT NOT NULL,
    selected_answer_id INT NOT NULL,
    is_correct         BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (attempt_id) REFERENCES user_attempts (id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions (id) ON DELETE CASCADE,
    FOREIGN KEY (selected_answer_id) REFERENCES answers (id) ON DELETE CASCADE
);

INSERT INTO quizzes (module_type, title, description, total_questions)
VALUES ('Customer Service', 'Basic Customer Service Quiz', 'Test your customer service knowledge', 5),
       ('IT-Security', 'Cybersecurity Fundamentals', 'Basic cybersecurity concepts and best practices', 5),
       ('General', 'General Security Awareness', 'General security awareness questions', 5);

INSERT INTO questions (quiz_id, question_text)
VALUES (1, 'Vad är viktigt att tänka på när man hanterar kunders personuppgifter?'),
       (1, 'Vilket av följande är ett exempel på stark autentisering?'),
       (1, 'Hur bör du agera om en kund ber dig dela deras lösenord?'),
       (1, 'Vad är GDPR:s huvudsakliga syfte?'),
       (1, 'Hur ska du hantera ett misstänkt phishingmejl från en kund?'),
       (1, 'Vilken information bör du undvika att skriva i ett öppet supportärende?'),
       (1, 'Vad innebär begreppet "Need to Know"?'),
       (1, 'Hur skyddar du kunddata i en delad arbetsmiljö?'),
       (1, 'Vad gör du om du misstänker att en kollega delar kunddata olämpligt?'),
       (1, 'Vilket är ett exempel på säkert kundbemötande online?'),
       (1, 'Hur hanterar du kundens ID-verifiering på ett säkert sätt?'),
       (1, 'Vad är bästa praxis för att stänga ett supportärende?'),
       (1, 'Hur ska du förhindra obehörig åtkomst till kundsystemet?'),
       (1, 'Vilket är ett tecken på social engineering vid kundkontakt?'),
       (1, 'Varför är det viktigt att logga ut från kundsystemet när du är klar?'),
       (2, 'Vad är phishing?'),
       (2, 'Vilken typ av malware krypterar dina filer och kräver betalning?'),
       (2, 'Vad är syftet med en brandvägg?'),
       (2, 'Vilket av följande är ett exempel på tvåfaktorsautentisering?'),
       (2, 'Hur skyddar du bäst ditt lösenord?'),
       (2, 'Vad är ett säkert sätt att dela filer med kollegor?'),
       (2, 'Vad innebär ”man-in-the-middle”-attack?'),
       (2, 'Vilken protokoll används för säker webbtrafik?'),
       (2, 'Vad är ett VPN och varför används det?'),
       (2, 'Hur kan du upptäcka ett skadligt e-postmeddelande?'),
       (2, 'Vad är brute force attack?'),
       (2, 'Vad innebär principle of least privilege?'),
       (2, 'Vad är ransomware?'),
       (2, 'Vilket verktyg kan användas för att upptäcka intrång i nätverk?'),
       (2, 'Hur ofta bör man uppdatera program och operativsystem?'),
       (3, 'Vad är social engineering?'),
       (3, 'Vilket av följande är ett säkert lösenord?'),
       (3, 'Hur skyddar du dig mot skadlig programvara?'),
       (3, 'Vad bör du göra om du hittar en USB-sticka på jobbet?'),
       (3, 'Vilket är ett tecken på phishing på nätet?'),
       (3, 'Varför ska du inte använda samma lösenord på flera konton?'),
       (3, 'Hur skyddar du din mobila enhet?'),
       (3, 'Vad är en säker surfvanor på offentliga Wi-Fi-nätverk?'),
       (3, 'Hur hanterar du misstänkta bilagor i e-post?'),
       (3, 'Vad är tvåstegsverifiering?'),
       (3, 'Vilken är bästa praxis för borttagning av känslig information?'),
       (3, 'Vad är viktigt vid lösenordshantering i företaget?'),
       (3, 'Vilken fysisk säkerhetsåtgärd är viktig på kontoret?'),
       (3, 'Hur känner du igen en säker webbplats?'),
       (3, 'Vad är ett tecken på insider hot i företaget?');



INSERT INTO answers (question_id, answer_text, is_correct, answer_order)
VALUES
-- 1
(1, 'Dela endast med kollegor vid behov och enligt policy', TRUE, 1),
(1, 'Spara på skrivbordet för snabb åtkomst', FALSE, 2),
(1, 'Skicka via e-post utan kryptering', FALSE, 3),
(1, 'Lagra i privata anteckningar', FALSE, 4),

-- 2
(2, 'Tvåfaktorsautentisering (2FA)', TRUE, 1),
(2, 'Enbart användarnamn', FALSE, 2),
(2, 'Födelsedatum som lösenord', FALSE, 3),
(2, 'Delat konto', FALSE, 4),

-- 3
(3, 'Informera kunden att lösenord är konfidentiellt', TRUE, 1),
(3, 'Spara lösenordet åt kunden', FALSE, 2),
(3, 'Skicka via SMS', FALSE, 3),
(3, 'Anteckna i kundkortet', FALSE, 4),

-- 4
(4, 'Skydda individers personuppgifter', TRUE, 1),
(4, 'Förbjuda reklam', FALSE, 2),
(4, 'Öka intern försäljning', FALSE, 3),
(4, 'Reglera e-postkommunikation', FALSE, 4),

-- 5
(5, 'Rapportera till IT och svara inte', TRUE, 1),
(5, 'Öppna länken för att kontrollera', FALSE, 2),
(5, 'Vidarebefordra till kollega', FALSE, 3),
(5, 'Svara med kunddata', FALSE, 4),

-- 6
(6, 'Personnummer', FALSE, 1),
(6, 'Fullständigt kreditkortsnummer', FALSE, 2),
(6, 'Interna lösenord', FALSE, 3),
(6, 'Allt ovanstående', TRUE, 4),

-- 7
(7, 'Tillgång ges endast till dem som behöver det', TRUE, 1),
(7, 'Alla får se all data', FALSE, 2),
(7, 'Delning ökar effektivitet', FALSE, 3),
(7, 'Behov avgörs av användaren själv', FALSE, 4),

-- 8
(8, 'Lås skärmen när du lämnar platsen', TRUE, 1),
(8, 'Spara kundlistor öppet', FALSE, 2),
(8, 'Dela dator med kollegor', FALSE, 3),
(8, 'Använd USB-minne utan kryptering', FALSE, 4),

-- 9
(9, 'Rapportera enligt intern policy', TRUE, 1),
(9, 'Ignorera situationen', FALSE, 2),
(9, 'Diskutera med kollegan', FALSE, 3),
(9, 'Publicera internt', FALSE, 4),

-- 10
(10, 'Använd säkra chattar med verifiering', TRUE, 1),
(10, 'Ge kundens data till tredje part', FALSE, 2),
(10, 'Använd öppna forum', FALSE, 3),
(10, 'Undvik ID-verifiering', FALSE, 4),

-- 11
(11, 'Begär flera identifierande uppgifter', TRUE, 1),
(11, 'Acceptera första namnet', FALSE, 2),
(11, 'Ignorera verifiering', FALSE, 3),
(11, 'Fråga efter lösenordet', FALSE, 4),

-- 12
(12, 'Bekräfta lösning & tacka kunden', TRUE, 1),
(12, 'Stäng utan att informera', FALSE, 2),
(12, 'Ignorera feedback', FALSE, 3),
(12, 'Radera historik', FALSE, 4),

-- 13
(13, 'Använd stark autentisering', TRUE, 1),
(13, 'Skriv lösenord på papper', FALSE, 2),
(13, 'Dela konton', FALSE, 3),
(13, 'Använd publika nätverk', FALSE, 4),

-- 14
(14, 'Personen pressar dig att bryta policy', TRUE, 1),
(14, 'Kunden tackar för hjälpen', FALSE, 2),
(14, 'Frågor om öppettider', FALSE, 3),
(14, 'Vanliga felsökningsfrågor', FALSE, 4),

-- 15
(15, 'För att förhindra obehörig åtkomst', TRUE, 1),
(15, 'För att snabba upp datorn', FALSE, 2),
(15, 'För att spara energi', FALSE, 3),
(15, 'För att avsluta program', FALSE, 4),

-- 1
(16, 'Försök att lura användare att lämna ut känslig information', TRUE, 1),
(16, 'En typ av antivirusprogram', FALSE, 2),
(16, 'En brandväggsinställning', FALSE, 3),
(16, 'En säkerhetscertifiering', FALSE, 4),

-- 2
(17, 'Ransomware', TRUE, 1),
(17, 'Trojan', FALSE, 2),
(17, 'Adware', FALSE, 3),
(17, 'Spyware', FALSE, 4),

-- 3
(18, 'Blockera obehörig trafik och skydda nätverk', TRUE, 1),
(18, 'Förbättra hårdvaruprestanda', FALSE, 2),
(18, 'Kryptera e-post', FALSE, 3),
(18, 'Övervaka användarbeteende', FALSE, 4),

-- 4
(19, 'Lösenord + SMS-kod', TRUE, 1),
(19, 'Enbart lösenord', FALSE, 2),
(19, 'Användarnamn', FALSE, 3),
(19, 'E-postadress', FALSE, 4),

-- 5
(20, 'Använd starka, unika lösenord och lösenordshanterare', TRUE, 1),
(20, 'Skriv ner på post-it', FALSE, 2),
(20, 'Dela med kollegor', FALSE, 3),
(20, 'Återanvänd samma lösenord överallt', FALSE, 4),

-- 6
(21, 'Använd kryptering och säkra molntjänster', TRUE, 1),
(21, 'Skicka via vanlig e-post', FALSE, 2),
(21, 'Ladda upp på öppna forum', FALSE, 3),
(21, 'Använd USB utan lösenord', FALSE, 4),

-- 7
(22, 'Att avlyssna kommunikationen mellan två parter', TRUE, 1),
(22, 'Att hacka ett lösenord med program', FALSE, 2),
(22, 'Att installera antivirus', FALSE, 3),
(22, 'Att skicka spam', FALSE, 4),

-- 8
(23, 'HTTPS', TRUE, 1),
(23, 'HTTP', FALSE, 2),
(23, 'FTP', FALSE, 3),
(23, 'SMTP', FALSE, 4),

-- 9
(24, 'Skapar en krypterad tunnel för säkrare kommunikation', TRUE, 1),
(24, 'Blockerar malware', FALSE, 2),
(24, 'Håller datorn snabb', FALSE, 3),
(24, 'Rensar cookies', FALSE, 4),

-- 10
(25, 'Kollar avsändaradress, stavfel och länkar', TRUE, 1),
(25, 'Öppna alla bilagor', FALSE, 2),
(25, 'Klicka på alla länkar', FALSE, 3),
(25, 'Svara direkt med känslig info', FALSE, 4),

-- 11
(26, 'Försök att gissa lösenord med systematiska försök', TRUE, 1),
(26, 'Fysiskt stjäla datorn', FALSE, 2),
(26, 'Skicka phishingmejl', FALSE, 3),
(26, 'Använda antivirus', FALSE, 4),

-- 12
(27, 'Användare får bara de behörigheter de behöver', TRUE, 1),
(27, 'Alla får full tillgång', FALSE, 2),
(27, 'Delad åtkomst minskar risk', FALSE, 3),
(27, 'Bevilja åtkomst efter behov av användare', FALSE, 4),

-- 13
(28, 'Skadlig kod som krypterar filer och kräver betalning', TRUE, 1),
(28, 'Brandvägg', FALSE, 2),
(28, 'VPN', FALSE, 3),
(28, 'Antivirus', FALSE, 4),

-- 14
(29, 'Intrusion Detection System (IDS)', TRUE, 1),
(29, 'Word Processor', FALSE, 2),
(29, 'Firewall', FALSE, 3),
(29, 'VPN', FALSE, 4),

-- 15
(30, 'Så ofta som uppdateringar finns tillgängliga', TRUE, 1),
(30, 'Aldrig', FALSE, 2),
(30, 'Endast vid problem', FALSE, 3),
(30, 'En gång per år', FALSE, 4),

-- 16
(31, 'Manipulation av personer för att få tillgång till information', TRUE, 1),
(31, 'Ett antivirusprogram', FALSE, 2),
(31, 'Brandväggsregel', FALSE, 3),
(31, 'Lösenordsåterställning', FALSE, 4),

-- 17
(32, 'Xy!9@Pq4#', TRUE, 1),
(32, 'password123', FALSE, 2),
(32, 'abc123', FALSE, 3),
(32, '123456', FALSE, 4),

-- 18
(33, 'Installera uppdaterad antivirus och håll system uppdaterade', TRUE, 1),
(33, 'Klicka på alla länkar', FALSE, 2),
(33, 'Dela dator med kollegor', FALSE, 3),
(33, 'Ignorera säkerhetsvarningar', FALSE, 4),

-- 19
(34, 'Lämna den till IT för säker hantering', TRUE, 1),
(34, 'Sätt i den i datorn direkt', FALSE, 2),
(34, 'Ta hem den', FALSE, 3),
(34, 'Ge till kollega utan kontroll', FALSE, 4),

-- 20
(35, 'Stavfel, konstiga länkar och oväntade bilagor', TRUE, 1),
(35, 'Kända avsändare', FALSE, 2),
(35, 'Professionellt språk', FALSE, 3),
(35, 'Signatur i mejl', FALSE, 4),

-- 21
(36, 'Förhindrar att om ett konto blir hackat, alla andra också blir det', TRUE, 1),
(36, 'Gör det enklare att komma ihåg', FALSE, 2),
(36, 'Sparar tid', FALSE, 3),
(36, 'Ökar nätverksprestanda', FALSE, 4),

-- 22
(37, 'Använd PIN och biometrik, lås telefonen', TRUE, 1),
(37, 'Dela med kollegor', FALSE, 2),
(37, 'Skriv ner koden', FALSE, 3),
(37, 'Stäng av lösenordet', FALSE, 4),

-- 23
(38, 'Använd VPN och undvik att logga in på känsliga konton', TRUE, 1),
(38, 'Använd öppet Wi-Fi utan skydd', FALSE, 2),
(38, 'Dela lösenord över Wi-Fi', FALSE, 3),
(38, 'Använd offentlig dator', FALSE, 4),

-- 24
(39, 'Öppna aldrig misstänkta bilagor, verifiera avsändaren', TRUE, 1),
(39, 'Öppna direkt', FALSE, 2),
(39, 'Vidarebefordra till alla', FALSE, 3),
(39, 'Spara på skrivbordet', FALSE, 4),

-- 25
(40, 'Extra säkerhetssteg utöver lösenord', TRUE, 1),
(40, 'En typ av virus', FALSE, 2),
(40, 'Endast lösenord', FALSE, 3),
(40, 'Säker e-post', FALSE, 4),

-- 26
(41, 'Krossa hårddisk eller radera säkert via program', TRUE, 1),
(41, 'Släng i papperskorg', FALSE, 2),
(41, 'Lämna på skrivbordet', FALSE, 3),
(41, 'Spara på USB', FALSE, 4),

-- 27
(42, 'Använd starka lösenord, undvik återanvändning', TRUE, 1),
(42, 'Alla får veta alla lösenord', FALSE, 2),
(42, 'Skriv ner på papper', FALSE, 3),
(42, 'Använd samma lösenord för alla', FALSE, 4),

-- 28
(43, 'Lås dörrar och säkerhetskort', TRUE, 1),
(43, 'Ha dörren öppen', FALSE, 2),
(43, 'Dela nycklar med alla', FALSE, 3),
(43, 'Lämna skrivbord obevakat', FALSE, 4),

-- 29
(44, 'HTTPS och låsikon i webbläsaren', TRUE, 1),
(44, 'HTTP', FALSE, 2),
(44, 'Webbplatsens färger', FALSE, 3),
(44, 'Stora bilder', FALSE, 4),

-- 30
(45, 'Ovanliga beteenden från anställda, ex. dataläckor', TRUE, 1),
(45, 'Anställda som tar kaffe', FALSE, 2),
(45, 'Normala e-postsignaturer', FALSE, 3),
(45, 'Standardarbetsrutiner', FALSE, 4);


UPDATE quizzes
SET total_questions = 5
WHERE id = 1;
