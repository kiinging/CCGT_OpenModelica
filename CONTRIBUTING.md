# Contributing to CCGT OpenModelica

Thank you for your interest in contributing to the CCGT OpenModelica project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- Clear title and description
- Steps to reproduce
- Expected vs actual behavior
- OpenModelica version
- Operating system

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use a clear descriptive title
- Provide detailed description of the enhancement
- Explain why this would be useful
- Include example use cases

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/CCGT_OpenModelica.git
   cd CCGT_OpenModelica
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow the code style (see below)
   - Add comments to your code
   - Update documentation if needed
   - Test your changes

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: Brief description of your changes"
   ```
   
   Commit message format:
   - `Add:` for new features
   - `Fix:` for bug fixes
   - `Update:` for updates to existing features
   - `Doc:` for documentation changes

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Describe your changes

## Code Style Guidelines

### Modelica Code

```modelica
// Use descriptive variable names
parameter SI.Temperature T_inlet = 288.15 "Compressor inlet temperature";

// Add units and descriptions to all parameters
parameter Real eta_c = 0.88 "Compressor isentropic efficiency";

// Group related parameters
// Compressor parameters
parameter SI.Pressure P1 = 101325;
parameter Real PR = 18;

// Add comments for complex equations
// Calculate isentropic outlet temperature using polytropic relation
T2s = T1 * (PR ^ ((gamma - 1) / gamma));
```

### Python Code

```python
# Follow PEP 8 style guide
# Use descriptive variable names
def read_openmodelica_mat(filename):
    """
    Read OpenModelica result file.
    
    Args:
        filename: Path to MAT file
        
    Returns:
        Dictionary with variable names and data
    """
    # Implementation
```

### Documentation

- Use clear, concise language
- Include examples where helpful
- Update README.md if adding new features
- Add comments to code for clarity

## Development Setup

### Prerequisites

- OpenModelica 1.23.0+
- Python 3.8+
- Git

### Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/CCGT_OpenModelica.git
cd CCGT_OpenModelica

# Install Python dependencies
pip install -r scripts/requirements.txt

# Run tests (if available)
# pytest tests/
```

## Testing

Before submitting a pull request:

1. **Test your model**
   ```bash
   cd scripts
   omc simulate_dynamic.mos
   ```

2. **Verify results**
   - Check that efficiency is reasonable (35-45%)
   - Verify power output is positive
   - Ensure no compilation errors

3. **Test documentation**
   - Check that README renders correctly
   - Verify links work
   - Ensure examples are accurate

## Areas for Contribution

### High Priority

- [ ] HRSG (Heat Recovery Steam Generator) model
- [ ] Steam turbine integration
- [ ] Control system implementation
- [ ] Emission calculations (NOx, CO2)

### Medium Priority

- [ ] Off-design performance maps
- [ ] Start-up/shutdown sequences
- [ ] Economic analysis module
- [ ] Additional validation cases

### Documentation

- [ ] Video tutorials
- [ ] More examples
- [ ] FAQ section
- [ ] Troubleshooting guide

## Questions?

- Open an issue for general questions
- Use discussions for broader topics
- Contact maintainers for sensitive issues

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Acknowledged in citations

Thank you for contributing! 🚀
