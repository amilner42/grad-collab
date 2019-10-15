import { Request, Response, NextFunction } from "express";
import { check } from "express-validator";
import { User, UserDocument, prepareForClient } from "../models/User";
import { TaskRequest } from "../models/TaskRequest";
import R from "ramda";


export const postTaskRequestValidators = [
    check("researchField", "Research field cannot be blank").isLength({min: 1}),
    check("researchSubject", "Research subject cannot be blank").isLength({min: 1}),
    check("projectImpactSummary", "Projct impact summary cannot be blank").isLength({min: 1}),
    check("fieldRequestingHelpFrom", "Field requesting help from cannot be blank").isLength({min: 1}),
    check("expectedTasksAndSkills", "Expected tasks and skills cannot be blank").isLength({min: 1}),
    check("reward", "Reward cannot be blank").isLength({min: 1}),
];


/**
 * POST /task-requests
 * Create a new task-request for the currently logged-in user.
 */
export const postTaskRequest = (req: Request, res: Response, next: NextFunction) => {

    if (!req.user) {
        return res.sendStatus(401);
    }

    const user = req.user as UserDocument;

    const taskRequest = new TaskRequest({
        researchField: req.body.researchField,
        researchSubject: req.body.researchSubject,
        projectImpactSummary: req.body.projectImpactSummary,
        fieldRequestingHelpFrom: req.body.fieldRequestingHelpFrom,
        expectedTasksAndSkills: req.body.expectedTasksAndSkills,
        reward: req.body.reward,
        additionalInfo: req.body.additionalInfo,
        userId: user.id
    });

    taskRequest.save((err, taskRequest) => {
        if (err) { return next(err); }

        return res.status(200).json({ taskRequestId: taskRequest.id });
    });

};


/**
 * GET /task-requests/:id
 *
 * Gets a task-request by it's ID. An optional `withUser` query param attaches the owner to the result.
 */
export const getTaskRequest = (req: Request, res: Response, next: NextFunction) => {
    const taskRequestId = req.params.id;
    const withUser = req.query.withUser === "1";

    TaskRequest.findById(taskRequestId).exec((err, taskRequest) => {
        if (err) {
            return next(err);
        }

        if (!withUser) {
            return res.status(200).json(taskRequest);
        }

        User.findById(taskRequest.userId, (err, user) => {

            if (err) {
                return next(err);
            }

            const result = {
                user: prepareForClient(user),
                taskRequest
            };

            return res.status(200).json(result);
        });

    });
};


/**
 * GET /task-requests
 * Get task requests configurable by some query params:
 *  - forUserId
 *  - researchField
 *  - fieldRequestingHelpFrom
 */
export const getTaskRequests = (req: Request, res: Response, next: NextFunction) => {

    const forUserId = req.query.forUserId;
    const researchField = req.query.researchField;
    const fieldRequestingHelpFrom = req.query.fieldRequestingHelpFrom;

    const searchBy = {
        ...(forUserId ? { userId: forUserId } : { }),
        ...(researchField ? { researchField: researchField } : { }),
        ...(fieldRequestingHelpFrom ? { fieldRequestingHelpFrom: fieldRequestingHelpFrom } : { })
    };

    TaskRequest.find(searchBy, (err, taskRequests) => {

        if (err) {
            return next(err);
        }

        return res.status(200).json(taskRequests);
    });

};
