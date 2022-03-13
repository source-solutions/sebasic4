;	// MARKDOWN - A file viewer for a subset of Markdown features
;	// Copyright (c) 2022 Source Solutions, Inc.

    org 40000;



buffer:
	defb "# heading 1", 13;
	defb "## heading 2", 13;
	defb "### heading 3", 13;
	defb "#### heading 4", 13;
	defb "##### heading 5", 13;
	defb "###### heading 6", 13;
	defb "This is a [link](#link).", 13;
	defb "This is **bold - abc1234567890**.", 13;
	defb "This is _italic - abc1234567890_.", 13;
	defb "***", 13;
	defb "\\ \[ \] \| \_ \**"
	defb "* bullet"
	defb "```"
	defb "code block"
	defb "```"
	defb 0

flags:
	defb 0;


