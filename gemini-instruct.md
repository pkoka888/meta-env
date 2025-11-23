This is the "bootstrapping" phase. Since you like CLI and structural thinking, we are going to build your \*\*Command Center\*\* in `.meta-env`.



Here is the step-by-step guide to turning those templates into a working system right now.



\### Phase 1: The Setup (Do this once)



We need to physically create the files I drafted for you in your `.meta-env` project.



\*\*1. Open your terminal (VS Code or SSH) and run this:\*\*

```bash

\# Go to your meta project

cd /home/pavel/projects/.meta-env/



\# Create the structure

mkdir -p templates/roles

mkdir -p templates/plans

mkdir -p scripts



\# Create the empty files (we will paste the content in a moment)

touch templates/roles/01\_orchestrator\_prompt.md

touch templates/roles/02\_sysadmin\_constitution.md

touch templates/plans/03\_server\_upgrade\_plan.md

touch scripts/04\_cli\_installer.sh

```



\*\*2. Paste the Content\*\*

\*   Copy the content of \*\*Artifact 01\*\* into `templates/roles/01\_orchestrator\_prompt.md`.

\*   Copy the content of \*\*Artifact 02\*\* into `templates/roles/02\_sysadmin\_constitution.md`.

\*   Copy the content of \*\*Artifact 03\*\* into `templates/plans/03\_server\_upgrade\_plan.md`.



---



\### Phase 2: Initialize the "Brain" (Gemini 3 / Claude)



You mentioned you want a high-reasoning AI (Gemini 3 / Sonnet) to plan, and CLI agents to execute.



1\.  \*\*Open Gemini 3 or Claude.\*\*

2\.  \*\*Paste the content of `01\_MASTER\_ORCHESTRATOR\_PROMPT.md`\*\*.

3\.  \*\*Append this message:\*\*

&nbsp;   > "I am ready. Load the context of my server environment (Server60, 61, 62). Our first mission is to execute the 'SSH Tunnel \& MCP Reorganization' from my notes. Please analyze and give me the first step."



\*\*Why this works:\*\* You have now "programmed" the chat interface to stop acting like a chatbot and start acting like a Project Manager. It will force you to stick to the plan.



---



\### Phase 3: Configure the "Hands" (Cline / Kilo Code)



Your CLI agents (Cline) need to know the rules so they don't break your Debian servers.



\*\*1. Configure Cline Custom Instructions:\*\*

Open VS Code Settings for Cline (or create a `.clinerules` file in the root of your workspace) and paste this summary of the \*\*Sysadmin Constitution\*\*:



```markdown

\# CRITICAL INSTRUCTIONS

1\. CONTEXT: You are working on Debian 13 Servers (60, 61, 62).

2\. SAFETY: NEVER restart a service (apache/nginx/ssh) without running a syntax check first (e.g., `apache2ctl -t`).

3\. BACKUPS: Before editing ANY config file (like /etc/ssh/sshd\_config), create a backup: `cp file file.bak.$(date +%s)`.

4\. PERMISSIONS: You are user 'pavel' in group 'cli-agents'. You have RWX in /home/pavel/projects but RX in /var/www/projects.

5\. APPROACH: Read file -> Backup -> Edit -> Test Syntax -> Reload.

```



---



\### Phase 4: Execute "Task 0" (SSH Tunnels)



Now let's actually do the work you asked for (Reorganizing SSH tunnels).



\*\*1. Ask the Orchestrator (Gemini):\*\*

> "Generate the `~/.ssh/config` snippet for Server 60, 61, and 62 using the logic that 61 uses port 2261 and 62 uses 2262. Also, give me the command to test the connection."



\*\*2. The Orchestrator will output code.\*\*



\*\*3. Switch to VS Code Terminal (or Cline):\*\*

Paste the command provided by the Orchestrator.

\*   \*Example Cline Prompt:\* "Update my local SSH config with these hosts. Remember the safety rules: read the existing config first."



---



\### Summary of the Workflow

From now on, when you have a crazy idea stream:



1\.  \*\*Dump idea\*\* into \*\*Gemini 3\*\* (Running the Orchestrator Prompt).

2\.  \*\*Gemini\*\* cleans it up and says: "Here is `plan.md`. Step 1 is updating SSH keys."

3\.  \*\*You\*\* go to \*\*VS Code/Cline\*\* and say: "Do Step 1 from the plan. Here are the keys."

4\.  \*\*Cline\*\* executes safely because it has the \*\*Constitution\*\* loaded.



\*\*Ready to try the first step?\*\* Go copy Artifact 01 into Gemini and tell it to start planning the "SSH Tunnel Reorganization".

