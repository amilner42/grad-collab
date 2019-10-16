import mongoose from "mongoose";


export type TaskRequest = mongoose.Document & {
    researchField: string;
    researchSubject: string;
    projectImpactSummary: string;
    fieldRequestingHelpFrom: string;
    expectedTasksAndSkills: string;
    reward: string;
    additionalInfo: string;
    state: string;
    userId: string;
};


const taskRequestSchema = new mongoose.Schema({
    researchField: { type: String, required: true },
    researchSubject: { type: String, required: true },
    projectImpactSummary: { type: String, required: true },
    fieldRequestingHelpFrom: { type: String, required: true },
    expectedTasksAndSkills: { type: String, required: true },
    reward: { type: String, required: true },
    additionalInfo: { type: String },
    state: { type: String, required: true },
    userId: { type: String, required: true, index: true },
}, { timestamps: true });


export const TaskRequest = mongoose.model<TaskRequest>("TaskRequest", taskRequestSchema);
