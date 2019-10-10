import { Request, Response, NextFunction } from "express";
import { check, sanitize, validationResult } from "express-validator";
import { UserDocument } from "../models/User";
import { CollabRequest } from "../models/CollabRequest";


export const postCollabRequestValidators = [
    check("field", "Field cannot be blank").isLength({min: 1}),
    check("subject", "Subject cannot be blank").isLength({min: 1}),
    check("projectImpactSummary", "Projct impact summary cannot be blank").isLength({min: 1}),
    check("expectedTasks", "Expected tasks cannot be blank").isLength({min: 1}),
    check("expectedSkills", "Expected skills cannot be blank").isLength({min: 1}),
    check("expectedTime", "Expected time cannot be blank").isLength({min: 1}),
    check("offer", "Offer time cannot be blank").isLength({min: 1}),
];


/**
 * POST /collab-requests
 * Create a new collab-request for the currently logged-in user.
 */
export const postCollabRequest = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    const collabRequest = new CollabRequest({
        field: req.body.field,
        subject: req.body.subject,
        projectImpactSummary: req.body.projectImpactSummary,
        expectedTasks: req.body.expectedTasks,
        expectedSkills: req.body.expectedSkills,
        expectedTime: req.body.expectedTime,
        offer: req.body.offer,
        additionalInfo: req.body.additionalInfo,
        userId: user.id
    });

    collabRequest.save((err, collabRequest) => {
        if (err) { return next(err); }

        return res.status(200).json({ collabRequestId: collabRequest.id });
    });

};


/**
 * GET /collab-requests/:id
 * Gets a collab-request by it's ID.
 */
export const getCollabRequest = (req: Request, res: Response, next: NextFunction) => {
    const collabRequestId = req.params.id;

    CollabRequest.findById(collabRequestId).exec((err, collabRequest) => {
        if (err) {
            return next(err);
        }

        return res.status(200).json(collabRequest);
    });
}
