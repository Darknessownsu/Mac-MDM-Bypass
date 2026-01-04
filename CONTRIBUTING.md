# Contributing to MAC MDM Evasion Utility

Thank you for considering contributing to this project. Please read these guidelines before submitting any contributions.

## Legal Disclaimer

By contributing to this project, you acknowledge that:
- This software is intended for **educational purposes only**
- Contributors are not liable for misuse of this software
- All contributions must comply with applicable laws and regulations
- You have the right to contribute the code you submit

## Code Quality Standards

### Shell Scripting Best Practices

All bash scripts must:
- Pass `shellcheck` with no warnings or errors
- Use proper quoting to prevent word splitting
- Include the `-r` flag with `read` commands
- Use safe file operations (no unprotected `rm -rf`)
- Include error handling for critical operations

### Testing

Before submitting:
1. Run `shellcheck` on all modified scripts
2. Test on supported macOS versions (Big Sur, Monterey, Ventura, Sonoma)
3. Verify both evasion and reversion functions work correctly
4. Test with and without sudo privileges

### Code Style

- Use descriptive variable names
- Add comments for complex operations
- Keep functions focused and single-purpose
- Follow the existing code structure
- Maintain consistency between both script versions

## Submission Guidelines

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement-name`)
3. Make your changes
4. Test thoroughly
5. Commit with clear, descriptive messages
6. Push to your fork
7. Open a pull request with:
   - Clear description of changes
   - Explanation of why the change is needed
   - Test results on macOS versions
   - Any breaking changes highlighted

### Issues

When reporting bugs or requesting features:
- Use a clear, descriptive title
- Provide macOS version and system details
- Include steps to reproduce (for bugs)
- Explain expected vs actual behavior
- Include relevant log excerpts (sanitized of personal info)

## What to Contribute

### Welcome Contributions

- Bug fixes
- Performance improvements
- Better error handling
- Improved documentation
- Security enhancements
- macOS compatibility updates
- Code cleanup and refactoring

### Not Accepted

- Features that increase legal/ethical concerns
- Untested code changes
- Code that fails shellcheck
- Changes without clear benefit
- Breaking changes without discussion

## Security

If you discover a security vulnerability:
1. **Do not** open a public issue
2. Email the maintainer directly
3. Include detailed information
4. Allow time for a fix before public disclosure

## Questions?

Open an issue with the "question" label for:
- Clarification on contribution guidelines
- Technical implementation questions
- Feature discussion before implementation

---

**Remember:** This is an educational project. All contributors share responsibility for ensuring ethical use.
