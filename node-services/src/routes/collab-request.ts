import { Request, Response, NextFunction } from "express";
import { check } from "express-validator";
import { User, UserDocument, prepareForClient } from "../models/User";
import { CollabRequest } from "../models/CollabRequest";


export const postCollabRequestValidators = [
    check("field", "Field cannot be blank").isLength({min: 1}),
    check("subject", "Subject cannot be blank").isLength({min: 1}),
    check("projectImpactSummary", "Projct impact summary cannot be blank").isLength({min: 1}),
    check("expectedTasksAndSkills", "Expected tasks and skills cannot be blank").isLength({min: 1}),
    check("reward", "Reward cannot be blank").isLength({min: 1}),
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
        expectedTasksAndSkills: req.body.expectedTasksAndSkills,
        reward: req.body.reward,
        additionalInfo: req.body.additionalInfo,
        userId: user.id,
        invitedCollabs: []
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
    const withUser = req.query.withUser === "1";

    CollabRequest.findById(collabRequestId).exec((err, collabRequest) => {
        if (err) {
            return next(err);
        }

        if (!withUser) {
            return res.status(200).json(collabRequest);
        }

        User.findById(collabRequest.userId, (err, user) => {

            if (err) {
                return next(err);
            }

            const result = {
                user: prepareForClient(user),
                collabRequest
            }

            return res.status(200).json(result);
        });

    });
};


/**
 * GET /collab-requests
 * Get the collab requests created by the current logged in user.
 */
export const getCollabRequests = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    CollabRequest.find({ userId: user.id }, (err, collabRequests) => {

        if (err) {
            return next(err);
        }

        return res.status(200).json(collabRequests);
    });

};
