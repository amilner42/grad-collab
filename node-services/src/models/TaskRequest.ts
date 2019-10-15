import mongoose from "mongoose";


export type TaskRequest = mongoose.Document & {
    field: string;
    subject: string;
    projectImpactSummary: string;
    expectedTasksAndSkills: string;
    reward: string;
    additionalInfo: string;
    userId: string;
};


const taskRequestSchema = new mongoose.Schema({
    field: { type: String, required: true },
    subject: { type: String, required: true },
    projectImpactSummary: { type: String, required: true },
    expectedTasksAndSkills: { type: String, required: true },
    reward: { type: String, required: true },

    additionalInfo: { type: String },
    userId: { type: String, required: true, index: true },
}, { timestamps: true });


export const TaskRequest = mongoose.model<TaskRequest>("TaskRequest", taskRequestSchema);
