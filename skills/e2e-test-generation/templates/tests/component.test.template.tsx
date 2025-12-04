import { render, screen, fireEvent } from '@testing-library/react';
import { {{COMPONENT_NAME}} } from './{{COMPONENT_FILE}}';

describe('{{COMPONENT_NAME}}', () => {
  it('renders correctly with default props', () => {
    render(<{{COMPONENT_NAME}} {{DEFAULT_PROPS}} />);

    expect(screen.getByText('{{EXPECTED_TEXT}}')).toBeInTheDocument();
  });

  it('renders with custom props', () => {
    render(<{{COMPONENT_NAME}} {{CUSTOM_PROPS}} />);

    expect(screen.getByText('{{CUSTOM_TEXT}}')).toBeInTheDocument();
  });

  it('handles user interaction', async () => {
    const handleClick = vi.fn();
    render(<{{COMPONENT_NAME}} onClick={handleClick} />);

    const button = screen.getByRole('button');
    fireEvent.click(button);

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('updates when props change', () => {
    const { rerender } = render(<{{COMPONENT_NAME}} value="initial" />);
    expect(screen.getByText('initial')).toBeInTheDocument();

    rerender(<{{COMPONENT_NAME}} value="updated" />);
    expect(screen.getByText('updated')).toBeInTheDocument();
  });

  it('applies correct CSS classes', () => {
    const { container } = render(<{{COMPONENT_NAME}} className="custom-class" />);

    expect(container.firstChild).toHaveClass('custom-class');
  });

  it('is accessible', () => {
    render(<{{COMPONENT_NAME}} {{DEFAULT_PROPS}} />);

    const element = screen.getByRole('{{ROLE}}');
    expect(element).toBeInTheDocument();
    expect(element).toHaveAccessibleName();
  });
});
