const express = require('express');
const cors = require('cors');
const { BedrockAgentRuntimeClient, InvokeAgentCommand } = require('@aws-sdk/client-bedrock-agent-runtime');

const app = express();
app.use(cors());
app.use(express.json());

const client = new BedrockAgentRuntimeClient({ region: 'us-east-1' });
const AGENT_ID = '4EU9JDZKML';
const AGENT_ALIAS_ID = 'NSJKQMHAS3';

const studentData = {
    "S01": { name: "Aoife Byrne", instrument: "Violin", age: 10, scores: { tech: 58, music: 55, rep: 60, art: 62 }, context: "Development stage, working on Twinkle variations and basic bow technique" },
    "S02": { name: "Conor Walsh", instrument: "Flute", age: 12, scores: { tech: 70, music: 72, rep: 74, art: 68 }, context: "Intermediate stage, studying Bach Minuet and improving breath control" },
    "S03": { name: "Ella Murphy", instrument: "Piano", age: 14, scores: { tech: 82, music: 80, rep: 85, art: 78 }, context: "Advanced stage, preparing Chopin Nocturne and working on pedaling technique" },
    "S04": { name: "Rory Fitzpatrick", instrument: "Trumpet", age: 15, scores: { tech: 92, music: 78, rep: 76, art: 80 }, context: "Young Artist stage, strong technical skills but needs musicianship development" },
    "S05": { name: "Saoirse Nolan", instrument: "Voice", age: 17, scores: { tech: 85, music: 90, rep: 92, art: 94 }, context: "Young Artist stage, preparing for conservatory auditions with art song repertoire" }
};

app.post('/api/chat', async (req, res) => {
    const { studentId, conversationType, message, sessionId } = req.body;
    
    try {
        const student = studentData[studentId];
        const contextMessage = `[Student: ${student.name}, ${student.instrument}, Age ${student.age}]
[Scores - Technical: ${student.scores.tech}/100, Musicianship: ${student.scores.music}/100, Repertoire: ${student.scores.rep}/100, Artistry: ${student.scores.art}/100]
[Context: ${student.context}]
[Conversation Type: ${conversationType}]

Student: ${message}`;

        const command = new InvokeAgentCommand({
            agentId: AGENT_ID,
            agentAliasId: AGENT_ALIAS_ID,
            sessionId: sessionId,
            inputText: contextMessage
        });

        const response = await client.send(command);
        
        let aiResponse = '';
        for await (const chunk of response.completion) {
            if (chunk.chunk?.bytes) {
                aiResponse += new TextDecoder().decode(chunk.chunk.bytes);
            }
        }

        res.json({
            response: aiResponse,
            messageId: `msg-${Date.now()}`,
            sessionId: sessionId
        });
        
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: 'Failed to get AI response' });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 API server running on http://localhost:${PORT}`);
    console.log(`Agent ID: ${AGENT_ID}`);
    console.log(`Alias ID: ${AGENT_ALIAS_ID}`);
});
