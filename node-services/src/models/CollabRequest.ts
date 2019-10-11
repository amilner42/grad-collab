import mongoose from "mongoose";
import { HtmlAndText } from "../util/email";
import { WEB_CLIENT_ORIGIN } from "../util/secrets";


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
    invitedCollabs: string[];
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
    userId: { type: String, required: true, index: true },
    invitedCollabs: { type: [ String ], required: true }
}, { timestamps: true });




export const toHtmlAndTextForEmail = (collabRequestDocument: CollabRequestDocument): HtmlAndText => {

    // TODO remove grad-collab insertion
    const linkToApp = `${WEB_CLIENT_ORIGIN}/grad-collab/#/browse/${collabRequestDocument.id}`;

    const html = `<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">
        <head>
        <!--[if gte mso 9]><xml><o:OfficeDocumentSettings><o:AllowPNG/><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml><![endif]-->
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type"/>
        <meta content="width=device-width" name="viewport"/>
        <!--[if !mso]><!-->
        <meta content="IE=edge" http-equiv="X-UA-Compatible"/>
        <!--<![endif]-->
        <title></title>
        <!--[if !mso]><!-->
        <!--<![endif]-->
        <style type="text/css">
        		body {
        			margin: 0;
        			padding: 0;
        		}

        		table,
        		td,
        		tr {
        			vertical-align: top;
        			border-collapse: collapse;
        		}

        		* {
        			line-height: inherit;
        		}

        		a[x-apple-data-detectors=true] {
        			color: inherit !important;
        			text-decoration: none !important;
        		}
        	</style>
        <style id="media-query" type="text/css">
        		@media (max-width: 520px) {

        			.block-grid,
        			.col {
        				min-width: 320px !important;
        				max-width: 100% !important;
        				display: block !important;
        			}

        			.block-grid {
        				width: 100% !important;
        			}

        			.col {
        				width: 100% !important;
        			}

        			.col>div {
        				margin: 0 auto;
        			}

        			img.fullwidth,
        			img.fullwidthOnMobile {
        				max-width: 100% !important;
        			}

        			.no-stack .col {
        				min-width: 0 !important;
        				display: table-cell !important;
        			}

        			.no-stack.two-up .col {
        				width: 50% !important;
        			}

        			.no-stack .col.num4 {
        				width: 33% !important;
        			}

        			.no-stack .col.num8 {
        				width: 66% !important;
        			}

        			.no-stack .col.num4 {
        				width: 33% !important;
        			}

        			.no-stack .col.num3 {
        				width: 25% !important;
        			}

        			.no-stack .col.num6 {
        				width: 50% !important;
        			}

        			.no-stack .col.num9 {
        				width: 75% !important;
        			}

        			.video-block {
        				max-width: none !important;
        			}

        			.mobile_hide {
        				min-height: 0px;
        				max-height: 0px;
        				max-width: 0px;
        				display: none;
        				overflow: hidden;
        				font-size: 0px;
        			}

        			.desktop_hide {
        				display: block !important;
        				max-height: none !important;
        			}
        		}
        	</style>
        </head>
        <body class="clean-body" style="margin: 0; padding: 0; -webkit-text-size-adjust: 100%; background-color: #FFFFFF;">
        <!--[if IE]><div class="ie-browser"><![endif]-->
        <table bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="nl-container" role="presentation" style="table-layout: fixed; vertical-align: top; min-width: 320px; Margin: 0 auto; border-spacing: 0; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #FFFFFF; width: 100%;" valign="top" width="100%">
        <tbody>
        <tr style="vertical-align: top;" valign="top">
        <td style="word-break: break-word; vertical-align: top;" valign="top">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td align="center" style="background-color:#FFFFFF"><![endif]-->
        <div style="background-color:transparent;">
        <div class="block-grid" style="Margin: 0 auto; min-width: 320px; max-width: 500px; overflow-wrap: break-word; word-wrap: break-word; word-break: break-word; background-color: transparent;">
        <div style="border-collapse: collapse;display: table;width: 100%;background-color:transparent;">
        <!--[if (mso)|(IE)]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:transparent;"><tr><td align="center"><table cellpadding="0" cellspacing="0" border="0" style="width:500px"><tr class="layout-full-width" style="background-color:transparent"><![endif]-->
        <!--[if (mso)|(IE)]><td align="center" width="500" style="background-color:transparent;width:500px; border-top: 0px solid transparent; border-left: 0px solid transparent; border-bottom: 0px solid transparent; border-right: 0px solid transparent;" valign="top"><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 0px; padding-left: 0px; padding-top:5px; padding-bottom:5px;"><![endif]-->
        <div class="col num12" style="min-width: 320px; max-width: 500px; display: table-cell; vertical-align: top; width: 500px;">
        <div style="width:100% !important;">
        <!--[if (!mso)&(!IE)]><!-->
        <div style="border-top:0px solid transparent; border-left:0px solid transparent; border-bottom:0px solid transparent; border-right:0px solid transparent; padding-top:5px; padding-bottom:5px; padding-right: 0px; padding-left: 0px;">
        <!--<![endif]-->
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding-right: 10px; padding-left: 10px; padding-top: 10px; padding-bottom: 10px; font-family: Arial, sans-serif"><![endif]-->
        <div style="color:#555555;font-family:Arial, 'Helvetica Neue', Helvetica, sans-serif;line-height:1.2;padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <p style="font-size: 12px; line-height: 1.2; color: #555555; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; mso-line-height-alt: 14px; margin: 0;">Hello,</p>
        <p style="font-size: 12px; line-height: 1.2; color: #555555; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; mso-line-height-alt: 14px; margin: 0;"> </p>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">You have been invited to discuss a possible collaboration on a research project. We have put the details for you below.</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Field</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.field}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Subject</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.subject}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Project Impact Summary</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.projectImpactSummary}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Expected Tasks</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.expectedTasks}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Expected Time</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.expectedTime}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Offer</strong></div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.offer}</div>
        <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>
        ${collabRequestDocument.additionalInfo.length == 0
            ? ""
            : `<div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"><strong>Additional Info</strong></div>
            <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;">${collabRequestDocument.additionalInfo}</div>
            <div style="font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; font-size: 12px; line-height: 1.2; color: #555555; mso-line-height-alt: 14px;"> </div>`
        }
        </div>
        <!--[if mso]></td></tr></table><![endif]-->
        <div align="center" class="button-container" style="padding-top:10px;padding-right:10px;padding-bottom:10px;padding-left:10px;">
        <!--[if mso]><table width="100%" cellpadding="0" cellspacing="0" border="0" style="border-spacing: 0; border-collapse: collapse; mso-table-lspace:0pt; mso-table-rspace:0pt;"><tr><td style="padding-top: 10px; padding-right: 10px; padding-bottom: 10px; padding-left: 10px" align="center"><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="${linkToApp}" style="height:31.5pt; width:97.5pt; v-text-anchor:middle;" arcsize="10%" stroke="false" fillcolor="#3AAEE0"><w:anchorlock/><v:textbox inset="0,0,0,0"><center style="color:#ffffff; font-family:Arial, sans-serif; font-size:16px"><![endif]--><a href="${linkToApp}" style="-webkit-text-size-adjust: none; text-decoration: none; display: inline-block; color: #ffffff; background-color: #3AAEE0; border-radius: 4px; -webkit-border-radius: 4px; -moz-border-radius: 4px; width: auto; width: auto; border-top: 1px solid #3AAEE0; border-right: 1px solid #3AAEE0; border-bottom: 1px solid #3AAEE0; border-left: 1px solid #3AAEE0; padding-top: 5px; padding-bottom: 5px; font-family: Arial, 'Helvetica Neue', Helvetica, sans-serif; text-align: center; mso-border-alt: none; word-break: keep-all;" target="_blank"><span style="padding-left:20px;padding-right:20px;font-size:16px;display:inline-block;">
        <span style="font-size: 16px; line-height: 2; mso-line-height-alt: 32px;">View Project</span>
        </span></a>
        <!--[if mso]></center></v:textbox></v:roundrect></td></tr></table><![endif]-->
        </div>
        <!--[if (!mso)&(!IE)]><!-->
        </div>
        <!--<![endif]-->
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        <!--[if (mso)|(IE)]></td></tr></table></td></tr></table><![endif]-->
        </div>
        </div>
        </div>
        <!--[if (mso)|(IE)]></td></tr></table><![endif]-->
        </td>
        </tr>
        </tbody>
        </table>
        <!--[if (IE)]></div><![endif]-->
        </body>
        </html>
    `;

    const text = `Hello,

You have been invited to discuss a possible collaboration on a research project. We have put the details for you below.

Field
${collabRequestDocument.field}

Subject
${collabRequestDocument.subject}

Project Impact Summary
${collabRequestDocument.projectImpactSummary}

Expected Tasks
${collabRequestDocument.expectedTasks}

Expected Time
${collabRequestDocument.expectedTime}

Offer
${collabRequestDocument.offer}

${collabRequestDocument.additionalInfo.length === 0
    ? ""
    : `Additional Info
${collabRequestDocument.additionalInfo}

View Project:
${linkToApp}
`
}`;

    return {
        html,
        text
    };

};


export const CollabRequest = mongoose.model<CollabRequestDocument>("CollabRequest", collabRequestSchema);
