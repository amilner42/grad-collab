import mongoose from "mongoose";


export type CollabRequestDocument = mongoose.Document & {
    field: string;
    subject: string;
    projectImpactSummary: string;
    expectedTasks: string;
    expectedSkills: string;
    expectedTime: string;
    offer: string;
    additionalInfo: string;
    userId: string;
};


const collabRequestSchema = new mongoose.Schema({
    field: { type: String, required: true },
    subject: { type: String, required: true },
    projectImpactSummary: { type: String, required: true },
    expectedTasks: { type: String, required: true },
    expectedSkills: { type: String, required: true },
    expectedTime: { type: String, required: true },
    offer: { type: String, required: true },
    additionalInfo: { type: String },
    userId: { type: String, required: true, index: true }
}, { timestamps: true });


export const CollabRequest = mongoose.model<CollabRequestDocument>("CollabRequest", collabRequestSchema);
